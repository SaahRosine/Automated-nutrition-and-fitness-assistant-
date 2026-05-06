import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/constants/app_styles.dart';

class PerformanceLineChart extends StatelessWidget {
  const PerformanceLineChart({super.key});

  static final _spots = [
    const FlSpot(0, 4.2),
    const FlSpot(1, 5.6),
    const FlSpot(2, 5.1),
    const FlSpot(3, 6.4),
    const FlSpot(4, 5.9),
    const FlSpot(5, 7.0),
    const FlSpot(6, 6.5),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(labels[value.toInt()], style: AppTextStyles.caption.copyWith(color: AppColors.white54)),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
            barWidth: 4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.28), AppColors.primary.withOpacity(0.0)])),
          ),
        ],
        borderData: FlBorderData(show: false),
        minY: 3.5,
        maxY: 7.5,
      ),
    );
  }
}

class EnergyBarChart extends StatelessWidget {
  const EnergyBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 12,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                return SideTitleWidget(axisSide: meta.axisSide, child: Text(labels[value.toInt()], style: AppTextStyles.caption.copyWith(color: AppColors.white54)));
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(
          7,
          (index) {
            final values = [7.8, 8.5, 6.2, 9.0, 10.5, 6.8, 8.2];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  width: 16,
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primary]), toY: values[index],
                ),
              ],
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
