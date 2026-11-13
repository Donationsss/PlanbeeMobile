import 'package:flutter/material.dart';
import 'package:planbeemobile/perfil.dart';

class MainAppBar extends StatefulWidget {
  const MainAppBar({super.key});

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          "assets/logo.png",
          height: 50,
          width: 50,
        ),
        Text(
          "Planbee",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Perfil()),
            );
          },
          icon: const Icon(
            Icons.person,
            size: 35,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
