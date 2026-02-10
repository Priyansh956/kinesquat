import 'package:flutter/material.dart';
import './Screens/homepage.dart';
import './Screens/statistics.dart';
import './Screens/settings.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),      // Index 0
    const StatisticsPage(), // Index 1
    const SettingsPage(),   // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: _pages[_currentIndex],
          )
        ),
        bottomNavigationBar: NavigationBar(
            backgroundColor: Color.fromRGBO(35, 35, 35, 1),
            selectedIndex: _currentIndex,
            onDestinationSelected: (index){
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const[
              NavigationDestination(
                  icon: Icon(Icons.home),
                  label: "Home"
              ),
              NavigationDestination(
                  icon: Icon(Icons.bar_chart),
                  label: "Stats"
              ),
              NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: "Settings"
              ),
            ]
        ),
      ),
    );
  }
}
