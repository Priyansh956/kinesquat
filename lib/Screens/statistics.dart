import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late List<DateTime> dates;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    selectedDate = today;

    dates = List.generate(7, (index) {
      return today.subtract(Duration(days: 3 - index));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(35, 35, 35, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              //Top-Section
              SizedBox(
                  height: 48,
                  child: Text(
                    "Your workout history",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
              ),

              SizedBox(height: 16),

              // Date-switcher
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];

                    final isSelected =
                        date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ChoiceChip(
                        label: Text(date.day.toString()),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Card(),
                  SizedBox(width: 8,),
                  Card(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
