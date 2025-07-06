import 'package:flutter/material.dart';
import 'screens/map_screen.dart';
import 'screens/daily_plan_screen.dart';
import 'screens/record_screen.dart';
import 'screens/subway_screen.dart';

void main() {
  runApp(const BusanTripApp());
}

class BusanTripApp extends StatelessWidget {
  const BusanTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Busan Trip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MapScreen(),
    const DailyPlanScreen(),
    const RecordScreen(),
    const SubwayScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: '地圖'),
          BottomNavigationBarItem(icon: Icon(Icons.today), label: '行程'),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: '紀錄'),
          BottomNavigationBarItem(icon: Icon(Icons.subway), label: '地鐵'),
        ],
      ),
    );
  }
}
