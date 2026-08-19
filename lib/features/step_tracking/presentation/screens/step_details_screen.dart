import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../providers/step_provider.dart';

class StepDetailsScreen extends ConsumerStatefulWidget {
  const StepDetailsScreen({super.key});

  @override
  ConsumerState<StepDetailsScreen> createState() => _StepDetailsScreenState();
}

class _StepDetailsScreenState extends ConsumerState<StepDetailsScreen> {
  int _selectedDateIndex = 6;

  @override
  Widget build(BuildContext context) {
    final stepState = ref.watch(stepNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'ACTIVITY DETAILS',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildWeeklySelector(),
            const SizedBox(height: 20),
            _buildChartCard(stepState.currentSteps.toDouble()),
            const SizedBox(height: 20),
            _buildSummaryStats(stepState.distanceKm, stepState.calories),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySelector() {
    final now = DateTime.now();
    final List<DateTime> weekDays = List.generate(
      7,
          (index) => now.subtract(Duration(days: 6 - index)),
    );

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final date = weekDays[index];
          final isSelected = index == _selectedDateIndex;
          final dayName = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
              });
            },
            child: Container(
              width: 65,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF10B981) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.black : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.inter(
                      color: isSelected ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(double currentSteps) {
    int currentHour = DateTime.now().hour;
    int activeIndex = 0;

    if (currentHour >= 22) {
      activeIndex = 4;
    } else if (currentHour >= 18) {
      activeIndex = 3;
    } else if (currentHour >= 14) {
      activeIndex = 2;
    } else if (currentHour >= 10) {
      activeIndex = 1;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedDateIndex == 6 ? 'Steps Today' : 'Steps History',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 10000,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(color: Colors.white54, fontSize: 10);
                            String text;
                            switch (value.toInt()) {
                              case 0: text = '6AM'; break;
                              case 1: text = '10AM'; break;
                              case 2: text = '2PM'; break;
                              case 3: text = '6PM'; break;
                              case 4: text = '10PM'; break;
                              default: text = '';
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox.shrink();
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(color: Colors.white54, fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 2500,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.white.withOpacity(0.1),
                          strokeWidth: 1,
                          dashArray: [5, 5],
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        top: BorderSide.none,
                        right: BorderSide.none,
                      ),
                    ),
                    barGroups: [
                      _buildBar(0, _selectedDateIndex == 6 && activeIndex == 0 ? currentSteps : 0),
                      _buildBar(1, _selectedDateIndex == 6 && activeIndex == 1 ? currentSteps : 0),
                      _buildBar(2, _selectedDateIndex == 6 && activeIndex == 2 ? currentSteps : 0),
                      _buildBar(3, _selectedDateIndex == 6 && activeIndex == 3 ? currentSteps : 0),
                      _buildBar(4, _selectedDateIndex == 6 && activeIndex == 4 ? currentSteps : 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF10B981),
          width: 16,
          borderRadius: BorderRadius.circular(4),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10000,
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(double distance, double calories) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassStatCard(
            'DISTANCE',
            _selectedDateIndex == 6 ? '${distance.toStringAsFixed(2)} km' : '0.00 km',
            Icons.map_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGlassStatCard(
            'CALORIES',
            _selectedDateIndex == 6 ? '${calories.toStringAsFixed(0)} kcal' : '0 kcal',
            Icons.local_fire_department_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassStatCard(String title, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF10B981), size: 28),
              const SizedBox(height: 16),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}