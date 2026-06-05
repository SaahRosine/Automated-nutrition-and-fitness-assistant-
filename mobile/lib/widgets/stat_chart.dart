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
    final theme = Theme.of(context);
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
                  meta: meta,  // ← Changed from axisSide: meta.axisSide
                  child: Text(labels[value.toInt()], style: AppTextStyles.caption(context).copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5))),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _spots,
            isCurved: true,
            gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
            barWidth: 4,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.28), theme.colorScheme.primary.withOpacity(0.0)])),
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
    final theme = Theme.of(context);
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
                return SideTitleWidget(
                  meta: meta,  // ← Changed from axisSide: meta.axisSide
                  child: Text(labels[value.toInt()], style: AppTextStyles.caption(context).copyWith(color: theme.colorScheme.onBackground.withOpacity(0.5))),
                );
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
                  gradient: LinearGradient(colors: [theme.colorScheme.secondary, theme.colorScheme.primary]), toY: values[index],
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