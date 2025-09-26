import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'screens/home_screen.dart';
import 'screens/daily_plan_screen.dart';
import 'screens/record_screen.dart';
import 'screens/map_screen.dart';
import 'screens/subway_screen.dart';
import 'screens/budget_screen.dart';

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
        useMaterial3: true,
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
  int _selectedIndex = 2; // 預設首頁

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const DailyPlanScreen();
      case 1:
        return const RecordScreen();
      case 2:
        return const HomeScreen();
      case 3:
        return const BudgetScreen();
      case 4:
        return const MapScreen();
      case 5:
        return const SubwayScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        items: const [
          TabItem(icon: Icons.calendar_today_outlined, title: '行程'),
          TabItem(icon: Icons.photo_camera_outlined, title: '紀錄'),
          TabItem(icon: Icons.home, title: '首頁'),
          TabItem(icon: Icons.account_balance_wallet_outlined, title: '記帳'),
          TabItem(icon: Icons.map_outlined, title: '地圖'),
          TabItem(icon: Icons.subway_outlined, title: '地鐵'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int i) {
          setState(() {
            _selectedIndex = i;
          });
        },
      ),
    );
  }
}