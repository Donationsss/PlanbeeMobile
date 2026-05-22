import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(0xFFFFDA5E),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: 0,
      iconSize: 30.0,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled, color: Colors.black,), label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.calendarClock, color: Colors.black,), label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.clockEdit, color: Colors.black,), label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book, color: Colors.black,), label: "",
        ),
        BottomNavigationBarItem(
          icon: Icon(MdiIcons.cog, color: Colors.black,), label: "",
        ),
      ],
    );
  }
}
