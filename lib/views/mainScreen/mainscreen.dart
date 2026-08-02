import 'package:flutter/material.dart';

import '../home/home_view.dart' show HomeView;
import '../profile/profile_view.dart' show ProfileView;
import '../extraservices/extraservicesScreen.dart' show ExtraServicesView;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeView(),
    const ExtraServicesView(),
    const ProfileView(), // Replace with your ProfileView
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
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/home@2x.png',
              width: 28,
              height: 28,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/extra service@2x.png',
              width: 28,
              height: 28,
            ),
            label: 'Extra Service',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/profile@2x.png',
              width: 28,
              height: 28,
            ),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF0D9298), // Use your primary color
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
