import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_provider.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../services/workout_service.dart';
import '../widgets/step_widget.dart';
import '../widgets/repetition_timer_widget.dart';
import '../widgets/static_timer_widget.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final List<LatLng> _path = [];
  final MapController _mapController = MapController();
  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    final sessionProvider = context.read<SessionProvider>();
    
    // Request permissions
    final permissionsGranted = await sessionProvider.requestPermissions();
    
    if (!mounted) return;
    
    if (permissionsGranted) {
      // Start the session
      sessionProvider.startSession();
      
      // Subscribe to location updates
      sessionProvider.controller.locationService.positionStream.listen(
        (pos) {
          if (!mounted) return;
          final point = LatLng(pos.latitude, pos.longitude);

          setState(() {
            _path.add(point);
          });

          // Animate to new position only if we have points
          if (_path.isNotEmpty) {
            try {
              _mapController.move(_path.last, 15);
            } catch (e) {
              // Ignore map errors
              if (kDebugMode) print('Map error: $e');
            }
          }
        },
        onError: (e) {
          if (kDebugMode) print('Location error: $e');
        },
      );
      
      setState(() {
        _sessionStarted = true;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(sessionProvider.errorMessage ?? 'Permission denied')),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/home');
      });
    }
  }

  void _stopSession() async {
    final sessionProvider = context.read<SessionProvider>();
    final userProvider = context.read<UserProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    
    final sessionData = sessionProvider.stopSession(
      weightKg: userProvider.weight ?? 70,
      workoutType: 'running',
      intensity: 'moderate',
    );

    if (sessionData != null && mounted) {
      // Convert path to parcours format
      final parcours = {
        'coordinates': _path.map((point) => {
          'latitude': point.latitude,
          'longitude': point.longitude,
        }).toList(),
        'totalDistance': sessionData.distance,
      };

      // Submit workout to backend
      final workoutService = WorkoutService();
      final result = await workoutService.submitWorkout(
        workoutObjective: 'running',
        duration: sessionData.duration,
        distance: sessionData.distance.toInt(),
        parcours: parcours,
        reps: {'steps': sessionData.steps},
        calories: sessionData.calories,
      );

      if (!mounted) return;

      if (result.success) {
        // Refresh workout list
        await workoutProvider.fetchWorkouts();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session Saved!\nDistance: ${(sessionData.distance / 1000).toStringAsFixed(2)}km\nCalories: ${sessionData.calories}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout: ${result.error}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/home');
      });
    }
  }

  // Helper method to get polylines with correct typing
  List<Polyline<Object>> _getPolylines() {
    if (_path.length <= 1) return [];
    
    return [
      Polyline(
        points: _path,
        color: Colors.blue,
        strokeWidth: 4.0
      ),
    ];
  }

  // Helper method to get markers
  List<Marker> _getMarkers() {
    if (_path.isEmpty) return [];
    
    return [
      Marker(
        point: _path.last,
        width: 40,
        height: 40,
        child: const Icon(
          Icons.my_location,
          color: Colors.red,
          size: 24,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    
    // Use first location if available, otherwise use default
    final initialCenter = _path.isNotEmpty ? _path.first : const LatLng(51.5, -0.09);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Activity Tracker"),
            Text(
              sessionProvider.formattedTime,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_sessionStarted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit Activity?'),
                  content: const Text('Your session is still active. Do you want to stop it?'),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Continue'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.pop();
                        _stopSession();
                      },
                      child: const Text('Stop & Exit', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            } else {
              context.go('/home');
            }
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: !_sessionStarted
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Requesting permissions...'),
                ],
              ),
            )
          : Column(
              children: [
                // MAP - OpenStreetMap
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: initialCenter,
                      initialZoom: 15,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.mobile',
                      ),
                      PolylineLayer(
                        polylines: _getPolylines(),
                      ),
                      MarkerLayer(
                        markers: _getMarkers(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        StepWidget(session: sessionProvider.controller),
                        const Divider(),
                        const RepTimerWidget(),
                        const Divider(),
                        const StaticTimerWidget(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: sessionProvider.isSessionPaused
                              ? () => sessionProvider.resumeSession()
                              : () => sessionProvider.pauseSession(),
                          icon: Icon(
                            sessionProvider.isSessionPaused ? Icons.play_arrow : Icons.pause,
                          ),
                          label: Text(
                            sessionProvider.isSessionPaused ? 'Resume' : 'Pause',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _stopSession,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    if (_sessionStarted) {
      context.read<SessionProvider>().stopSession(
        weightKg: context.read<UserProvider>().weight ?? 70,
        workoutType: 'running',
        intensity: 'moderate',
      );
    }
    _mapController.dispose();
    super.dispose();
  }
}