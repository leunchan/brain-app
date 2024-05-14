import 'package:flutter/material.dart';
import 'package:moonje_mate/screen/setting_screen.dart';
import 'package:moonje_mate/screen/storage_screen.dart';

import 'chat_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // 화면 선택 위치ㅓ
  List<Widget> _screenType = [
    StorageScreen(),
    ChatScreen(),
    SettingScreen(),

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenType.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xff14ff00),
        unselectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '',
          ),
        ],
      ),
    );
  }
}
