import 'package:flutter/material.dart';
import 'package:ticket_at/my_widget/my_colors.dart';
import 'package:ticket_at/presintaion/home_page.dart';
import 'package:ticket_at/presintaion/my_ticket.dart';
import 'package:ticket_at/presintaion/profile_page.dart';

import 'my_event.dart';
import 'qr_scanner_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomePage(),
    const MyTicket(),
    const MyEvent(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerPage()),
          );
        },
        backgroundColor: MyColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 60,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavItem(icon: Icons.home, label: "Home", index: 0),
                _buildNavItem(
                  icon: Icons.confirmation_number,
                  label: "Ticket",
                  index: 1,
                ),
              ],
            ),

            const SizedBox(width: 40),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNavItem(
                  icon: Icons.festival,
                  label: "My Event",
                  index: 2,
                ),
                _buildNavItem(icon: Icons.person, label: "Profile", index: 3),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return MaterialButton(
      minWidth: 40,
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? MyColors.primary : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? MyColors.primary : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
