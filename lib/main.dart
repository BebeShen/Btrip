import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/daily_plan_screen.dart';
import 'screens/record_screen.dart';
import 'screens/map_screen.dart';
import 'screens/subway_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '釜山行 App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 2;

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const DailyPlanScreen();
      case 1:
        return const RecordScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const MapScreen();
      case 4:
        return const SubwayScreen();
      default:
        return const HomeScreen();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getIconColor(int index) {
    return _selectedIndex == index ? Colors.blue : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      floatingActionButton: Container(
        height: 56,  // 調整圓形按鈕尺寸
        width: 56,
        child: FloatingActionButton(
          onPressed: () => _onItemTapped(2),
          backgroundColor: _selectedIndex == 2 ? Colors.blue : Colors.grey,
          shape: const CircleBorder(),
          child: const Icon(Icons.home),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 0, // 調整 notch，讓 FAB 不會凸太高
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.calendar_today_outlined, color: _getIconColor(0)),
              onPressed: () => _onItemTapped(0),
            ),
            IconButton(
              icon: Icon(Icons.photo_camera_outlined, color: _getIconColor(1)),
              onPressed: () => _onItemTapped(1),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: Icon(Icons.map_outlined, color: _getIconColor(3)),
              onPressed: () => _onItemTapped(3),
            ),
            IconButton(
              icon: Icon(Icons.subway_outlined, color: _getIconColor(4)),
              onPressed: () => _onItemTapped(4),
            ),
          ],
        ),
      ),
    );
  }
}
