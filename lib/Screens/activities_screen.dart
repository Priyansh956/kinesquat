import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../widgets/dark_card.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = DateTime.now();
    final todayAbbr = DateFormat('E').format(today).substring(0, 3);
    final squatData = state.weeklySquats;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxSquats =
    squatData.values.fold(0, (m, v) => v > m ? v : m).toDouble();
    final weekDates =
    List.generate(7, (i) => today.subtract(Duration(days: 3 - i)));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────────────
            const Text('Your Activities',
                style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // ── Date strip ────────────────────────────────────────
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weekDates.length,
                itemBuilder: (context, i) {
                  final d = weekDates[i];
                  final isToday = d.day == today.day &&
                      d.month == today.month &&
                      d.year == today.year;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      border: isToday ? Border.all(color: Colors.white) : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isToday
                          ? 'Today, ${DateFormat("d MMM").format(d)}'
                          : '${d.day}',
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.white54,
                        fontSize: isToday ? 13 : 14,
                        fontWeight:
                        isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ── kCal + Sets row ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Steps',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Icon(Icons.directions_walk,
                                color: Colors.white54, size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: state.steps),
                          duration: const Duration(milliseconds: 500),
                          builder: (_, v, __) => Text(
                            v.toString(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Text('today',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        if (state.pedometerStatus == 'denied')
                          const Text('Permission denied',
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 10)),
                        if (state.pedometerStatus == 'unavailable')
                          const Text('Sensor unavailable',
                              style: TextStyle(
                                  color: Colors.orangeAccent, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DarkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sets',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 14)),
                            const Icon(Icons.view_column,
                                color: Colors.white54, size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: state.todaySets),
                          duration: const Duration(milliseconds: 500),
                          builder: (_, v, __) => Text('$v',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Text('sets',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 11)),
                        // Live indicator when tracking
                        if (state.isTracking)
                          Row(
                            children: [
                              Container(
                                width: 6, height: 6,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Text(
                                'Live · Set ${state.liveSets + 1}',
                                style: const TextStyle(
                                    color: Colors.greenAccent, fontSize: 10),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Squat bar chart ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Squats This Week',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                if (state.isTracking)
                  Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent, shape: BoxShape.circle,
                        ),
                      ),
                      const Text('Live',
                          style: TextStyle(
                              color: Colors.greenAccent, fontSize: 11)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: DarkCard(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                child: BarChart(
                  swapAnimationDuration: const Duration(milliseconds: 300),
                  BarChartData(
                    maxY: maxSquats == 0 ? 10 : maxSquats * 1.3,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: const Color(0xFF2A2A2A),
                        getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                          '${rod.toY.toInt()} reps',
                          const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final day = days[value.toInt()];
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(day,
                                  style: TextStyle(
                                    color: day == todayAbbr
                                        ? Colors.white
                                        : Colors.white54,
                                    fontSize: 10,
                                  )),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Colors.white12, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(days.length, (i) {
                      final day = days[i];
                      int count = squatData[day] ?? 0;
                      // Add live reps to today's bar while tracking
                      final isToday = day == todayAbbr;
                      if (isToday && state.isTracking) {
                        count += state.liveReps;
                      }
                      return BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: count.toDouble(),
                            color: isToday
                                ? Colors.pinkAccent
                                : Colors.greenAccent,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: maxSquats == 0 ? 10 : maxSquats * 1.3,
                              color: Colors.white10,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}