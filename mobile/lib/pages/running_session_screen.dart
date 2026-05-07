import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/core/constants/app_styles.dart';
import 'package:mobile/widgets/glass_card.dart';

class RunningSessionScreen extends StatelessWidget {
  const RunningSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white),
                  ),
                  Column(
                    children: [
                      Text('Live session', style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
                      const SizedBox(height: 6),
                      Text('Outdoor run', style: AppTextStyles.heading3),
                    ],
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('00:32:14', style: AppTextStyles.heading1.copyWith(fontSize: 48)),
                                  const SizedBox(height: 8),
                                  Text('Current pace', style: AppTextStyles.body.copyWith(color: AppColors.white70)),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(color: AppColors.white10, borderRadius: BorderRadius.circular(18)),
                                child: const Icon(Icons.pause, color: AppColors.secondary, size: 30),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sessionMetric('Pace', '4’35"', AppColors.primary),
                              _sessionMetric('Speed', '13.1 km/h', AppColors.secondary),
                              _sessionMetric('Distance', '6.4 km', AppColors.white),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sessionMetric('Calories', '432 kcal', AppColors.white54),
                              _sessionMetric('Steps', '8,120', AppColors.white54),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 650.ms),
                    const SizedBox(height: 22),
                    GlassCard(
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
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
                                    color: AppColors.secondary,
                                    strokeWidth: 5,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _controlButton(Icons.pause_circle_filled_rounded, 'Pause', AppColors.primary)),
                        const SizedBox(width: 14),
                        Expanded(child: _controlButton(Icons.stop_circle_rounded, 'Stop', AppColors.error)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _infoPanel('Heart rate', '168 bpm', AppColors.primary)),
                        const SizedBox(width: 14),
                        Expanded(child: _infoPanel('Elevation', '+28 m', AppColors.secondary)),
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

  Widget _sessionMetric(String label, String value, Color accent) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.heading3.copyWith(color: accent)),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, String label, Color color) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size.fromHeight(62),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.white),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _infoPanel(String title, String value, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading3.copyWith(color: accent)),
        ],
      ),
    );
  }
}
