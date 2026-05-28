import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/components/appbar.dart';


import 'components/bottombar.dart';

class Agenda extends StatefulWidget {
  const Agenda({super.key});

  @override
  State<Agenda> createState() => _AgendaState();
}

class _AgendaState extends State<Agenda> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDA5E),
        title: MainAppBar(),
        centerTitle: true,
      ),

      backgroundColor: const Color(0xFFFFF9CF),
      body: Center( // Centraliza tudo na tela
        child: Container(
          width: 350,
          height: 400,
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(23),
          ),

          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFDA5E),
              borderRadius: BorderRadius.circular(23),
            ),
            child: GridView.count(
              crossAxisCount: 7,
              childAspectRatio: 0.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
              children: [
                
              ]
            ),
          )
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
