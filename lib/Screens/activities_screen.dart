import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/app_state.dart';
import '../widgets/dark_card.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  final ScrollController _dateScrollCtrl = ScrollController();
  static const int _daysBack = 59; // show 60 days
  static const int _totalDays = _daysBack + 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollCtrl.hasClients) {
        _dateScrollCtrl.jumpTo(_dateScrollCtrl.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _dateScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // 60-day window ending today
    final dates = List.generate(
      _totalDays,
          (i) => todayNorm.subtract(Duration(days: _daysBack - i)),
    );

    // ── Week of selected date ─────────────────────────────────
    final sel = state.selectedDate;
    final selNorm = DateTime(sel.year, sel.month, sel.day);
    // Monday of selected week
    final selMonday = selNorm.subtract(Duration(days: selNorm.weekday - 1));
    // Labels: Mon d – Sun d for the selected week
    final weekDayLabels = List.generate(7, (i) {
      final d = selMonday.add(Duration(days: i));
      return DateFormat('E\nd').format(d); // e.g. "Mon\n18"
    });
    final weekDayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Squat data for the selected week
    final squatData = state.weeklySquats; // keyed Mon..Sun
    final maxY = squatData.values
        .fold(0, (m, v) => v > m ? v : m)
        .toDouble();

    // Which bar is "today" and which is "selected" within this week?
    final todayInWeek = today.difference(selMonday).inDays;
    final selInWeek = selNorm.difference(selMonday).inDays;

    // Week range header
    final weekLabel = selMonday.month == selMonday.add(const Duration(days: 6)).month
        ? '${DateFormat("d").format(selMonday)} – ${DateFormat("d MMM").format(selMonday.add(const Duration(days: 6)))}'
        : '${DateFormat("d MMM").format(selMonday)} – ${DateFormat("d MMM").format(selMonday.add(const Duration(days: 6)))}';

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Fixed heights so nothing overflows
          const dateStripH = 62.0;
          const dateLabelH = 20.0;
          const statsRowH = 100.0;
          const chartHeaderH = 28.0;
          const padding = 16.0 * 2;
          const gaps = 14.0 + 8.0 + 14.0 + 14.0 + 10.0 + 10.0; // all SizedBox gaps
          const titleH = 36.0;

          final chartH = constraints.maxHeight -
              titleH -
              dateStripH -
              dateLabelH -
              statsRowH -
              chartHeaderH -
              padding -
              gaps -
              24; // bottom buffer
          final safeChartH = chartH.clamp(120.0, 260.0);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title ──────────────────────────────────────────
                const SizedBox(
                  height: titleH,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Your Activities',
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Scrollable date strip ───────────────────────────
                SizedBox(
                  height: dateStripH,
                  child: ListView.builder(
                    controller: _dateScrollCtrl,
                    scrollDirection: Axis.horizontal,
                    itemCount: dates.length,
                    itemBuilder: (context, i) {
                      final d = dates[i];
                      final isToday = d == todayNorm;
                      final isSelected =
                          d.year == selNorm.year &&
                              d.month == selNorm.month &&
                              d.day == selNorm.day;
                      final hasData =
                          state.storage.getSessionsForDate(d).isNotEmpty ||
                              (isToday && state.isTracking);

                      return GestureDetector(
                        onTap: () => state.selectDate(d),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 44,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? Colors.white60
                                  : Colors.white24,
                              width: isToday && !isSelected ? 1.5 : 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('E').format(d).substring(0, 1),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.black54
                                      : Colors.white38,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.black
                                      : isToday
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: hasData
                                      ? (isSelected
                                      ? Colors.black38
                                      : Colors.greenAccent)
                                      : Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── Selected date label ─────────────────────────────
                SizedBox(
                  height: dateLabelH,
                  child: Text(
                    state.isSelectedDateToday
                        ? 'Today · ${DateFormat("d MMMM").format(sel)}'
                        : DateFormat('EEEE, d MMMM').format(sel),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Stats cards ─────────────────────────────────────
                SizedBox(
                  height: statsRowH,
                  child: Row(
                    children: [
                      // Steps — always today
                      Expanded(
                        child: DarkCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Steps',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                  const Icon(Icons.directions_walk,
                                      color: Colors.white38, size: 16),
                                ],
                              ),
                              TweenAnimationBuilder<int>(
                                tween:
                                IntTween(begin: 0, end: state.selectedDateSteps),
                                duration:
                                const Duration(milliseconds: 500),
                                builder: (_, v, __) => Text('$v',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text(state.isSelectedDateToday ? 'today' : DateFormat('d MMM').format(state.selectedDate),
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Sets — selected date
                      Expanded(
                        child: DarkCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sets',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                  const Icon(Icons.view_column,
                                      color: Colors.white38, size: 16),
                                ],
                              ),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(
                                    begin: 0,
                                    end: state.selectedDateSets),
                                duration:
                                const Duration(milliseconds: 400),
                                builder: (_, v, __) => Text('$v',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const Text('sets',
                                  style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 9)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Reps + kcal — selected date
                      Expanded(
                        child: DarkCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Reps',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                  const Icon(Icons.accessibility_new,
                                      color: Colors.white38, size: 16),
                                ],
                              ),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(
                                    begin: 0,
                                    end: state.selectedDateReps),
                                duration:
                                const Duration(milliseconds: 400),
                                builder: (_, v, __) => Text('$v',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ),
                              Text(
                                '~${state.selectedDateKcal.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 9),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Chart header ───────────────────────────────────
                SizedBox(
                  height: chartHeaderH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Week',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          Text(weekLabel,
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      if (state.isTracking && state.isSelectedDateToday)
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle),
                            ),
                            const Text('Live',
                                style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 10)),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Bar chart — fixed height, no Expanded ──────────
                SizedBox(
                  height: safeChartH,
                  child: DarkCard(
                    padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
                    child: BarChart(
                      swapAnimationDuration:
                      const Duration(milliseconds: 350),
                      BarChartData(
                        maxY: maxY == 0 ? 10 : maxY * 1.3,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Color(0xFF2A2A2A),
                            getTooltipItem: (group, _, rod, __) =>
                                BarTooltipItem(
                                  '${rod.toY.toInt()} reps',
                                  const TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 34,
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                final short = weekDayShort[idx];
                                final d = selMonday
                                    .add(Duration(days: idx));
                                final dayNum = d.day;
                                final isTodayBar =
                                    todayInWeek == idx &&
                                        todayInWeek >= 0 &&
                                        todayInWeek < 7;
                                final isSelBar = selInWeek == idx;

                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(short,
                                          style: TextStyle(
                                            color: isSelBar
                                                ? Colors.white
                                                : isTodayBar
                                                ? Colors.white60
                                                : Colors.white30,
                                            fontSize: 9,
                                            fontWeight: isSelBar
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          )),
                                      Text('$dayNum',
                                          style: TextStyle(
                                            color: isSelBar
                                                ? Colors.white
                                                : isTodayBar
                                                ? Colors.white60
                                                : Colors.white24,
                                            fontSize: 8,
                                          )),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                              sideTitles:
                              SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles:
                              SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles:
                              SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) =>
                          const FlLine(
                              color: Colors.white12,
                              strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups:
                        List.generate(weekDayShort.length, (i) {
                          final short = weekDayShort[i];
                          final count = squatData[short] ?? 0;
                          final isTodayBar = todayInWeek == i &&
                              todayInWeek >= 0 &&
                              todayInWeek < 7;
                          final isSelBar = selInWeek == i;

                          Color barColor;
                          if (isSelBar && isTodayBar) {
                            barColor = Colors.pinkAccent;
                          } else if (isSelBar) {
                            barColor = Colors.white;
                          } else if (isTodayBar) {
                            barColor = Colors.pinkAccent;
                          } else {
                            barColor = Colors.greenAccent;
                          }

                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: count.toDouble(),
                                color: barColor,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                                backDrawRodData:
                                BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxY == 0 ? 10 : maxY * 1.3,
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
          );
        },
      ),
    );
  }
}