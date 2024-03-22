import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/eco_coin_screen.dart';
import 'screens/about_screen.dart';
import 'widgets/bottom_navigation_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ShopScreen(),
    TasksScreen(),
    EcoCoinScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoFront',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBarWidget(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
