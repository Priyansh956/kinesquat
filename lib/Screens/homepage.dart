import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double get deviceHeight => MediaQuery.of(context).size.height;
  double get deviceWidth => MediaQuery.of(context).size.width;

  final List<String> timelineOptions = ["All", "Today", "This Week", "This Month"];
  int? _selectedTimeIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(35, 35, 35, 1),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Top-Section
                Row(
                  children: const [
                    Text(
                      "Tracking em!",
                      style: TextStyle(color: Colors.white, fontSize: 36),
                    ),
                    Spacer(),
                    CircleAvatar(radius: 24),
                  ],
                ),

                const SizedBox(height: 24),

                // Current Progress
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    color: Color.fromRGBO(23, 60, 56, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // LEFT SIDE
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        value: 0.72,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    Text(
                                      "72%",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  "Legs",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // RIGHT SIDE IMAGE
                        SizedBox(
                          width: 150,
                          height: double.infinity,
                          child: Image.asset(
                            'images/card1Img.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Timeline selector
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index){
                        return ChoiceChip(
                            label: Text(
                                timelineOptions[index],
                                style: TextStyle(
                                  color: Colors.purple,
                                ),

                            ),
                            selected: _selectedTimeIndex == index,

                            selectedColor: Colors.lightGreenAccent,
                            labelStyle: TextStyle(
                              color: _selectedTimeIndex == index ? Colors.blue : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),

                            onSelected: (bool isSelected) {
                              setState(() {
                                _selectedTimeIndex = isSelected ? index : null;
                              });
                            },
                        );
                      },
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemCount: timelineOptions.length,
                  )
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    color: Color.fromRGBO(23, 60, 56, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // LEFT SIDE
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        value: 0.72,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    Text(
                                      "72%",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  "Legs",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // RIGHT SIDE IMAGE
                        SizedBox(
                          width: 150,
                          height: double.infinity,
                          child: Image.asset(
                            'images/card1Img.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 16),

                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 5,
                    color: Color.fromRGBO(23, 60, 56, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        // LEFT SIDE
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: const [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        value: 0.72,
                                        strokeWidth: 6,
                                        backgroundColor: Colors.white24,
                                        valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    Text(
                                      "72%",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  "Legs",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // RIGHT SIDE IMAGE
                        SizedBox(
                          width: 150,
                          height: double.infinity,
                          child: Image.asset(
                            'images/card1Img.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}