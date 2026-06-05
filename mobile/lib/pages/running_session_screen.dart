import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/constants/app_styles.dart';

class RunningSessionScreen extends StatefulWidget {
  const RunningSessionScreen({super.key});

  @override
  State<RunningSessionScreen> createState() => _RunningSessionScreenState();
}

class _RunningSessionScreenState extends State<RunningSessionScreen> {
  bool _isPaused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onBackground),
                  ),
                  Column(
                    children: [
                      Text('Live session', style: AppTextStyles.caption(context)),
                      const SizedBox(height: 4),
                      Text('Outdoor run', style: AppTextStyles.heading3(context)),
                    ],
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('00:32:14', style: AppTextStyles.heading1(context).copyWith(fontSize: 48)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Current pace',
                                      style: AppTextStyles.body(context).copyWith(
                                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.pause, color: theme.colorScheme.secondary, size: 28),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _sessionMetric(context, 'Pace', '4\'35"', theme.colorScheme.primary),
                                _sessionMetric(context, 'Speed', '13.1 km/h', theme.colorScheme.secondary),
                                _sessionMetric(context, 'Distance', '6.4 km', theme.colorScheme.onBackground),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _sessionMetric(context, 'Calories', '432 kcal', theme.colorScheme.onBackground.withOpacity(0.6)),
                                _sessionMetric(context, 'Steps', '8,120', theme.colorScheme.onBackground.withOpacity(0.6)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(duration: 650.ms),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          height: 320,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(37.7786, -122.4375),
                              initialZoom: 13,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.stride.app',
                              ),
                              PolylineLayer(
                                polylines: [
                                  Polyline(
                                    points: [
                                      LatLng(37.7786, -122.4375),
                                      LatLng(37.7837, -122.4312),
                                      LatLng(37.7895, -122.4335),
                                      LatLng(37.7921, -122.4404),
                                    ],
                                    color: theme.colorScheme.secondary,
                                    strokeWidth: 5,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _controlButton(context, Icons.pause_circle_filled_rounded, _isPaused ? 'Resume' : 'Pause', theme.colorScheme.primary, () {
                          setState(() {
                            _isPaused = !_isPaused;
                          });
                        })),
                        const SizedBox(width: 16),
                        Expanded(child: _controlButton(context, Icons.stop_circle_rounded, 'Stop', AppColors.error, () {
                          Navigator.maybePop(context);
                        })),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _infoPanel(context, 'Heart rate', '168 bpm', theme.colorScheme.primary)),
                        const SizedBox(width: 16),
                        Expanded(child: _infoPanel(context, 'Elevation', '+28 m', theme.colorScheme.secondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sessionMetric(BuildContext context, String label, String value, Color accent) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.heading3(context).copyWith(color: accent)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption(context)),
        ],
      ),
    );
  }

  Widget _controlButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(56),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _infoPanel(BuildContext context, String title, String value, Color accent) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.caption(context)),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.heading3(context).copyWith(color: accent)),
          ],
        ),
      ),
    );
  }
}
