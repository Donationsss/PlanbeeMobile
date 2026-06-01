import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/components/appbar.dart';


import 'components/bottombar.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {

  Widget _buildDiaSemana(String nome, Color cor) { //precisa do _ pra fazer o novo widget
    return Column(
      children: [
        Text(nome, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        SizedBox(height: 10),
        Container(
          width: 35,
          height: 70,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black54, blurRadius: 2, spreadRadius: 0),
              BoxShadow(color: Colors.black12, blurRadius: 7, spreadRadius: 2,),
            ],
          ),
        ),
      ],
    );
  }

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
        child: Column(
          mainAxisSize: MainAxisSize.min, // Faz a coluna ocupar apenas o espaço necessário
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text("Semana 1", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_right, size: 60),
              ],
            ),
            SizedBox(height: 20),

            // cards
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54, blurRadius: 5,
                    offset: Offset(4, 4)
                  ),
                ],
                gradient: LinearGradient(
                    colors: [Color(0xffFFA53D), Color(0xffFFCA37)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDiaSemana("Seg", Colors.white,),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Ter", Colors.white),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Qua", Colors.white),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Qui", Colors.white),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Sex", Colors.white),
                ],
              ),
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Row(
                children: [
                  SizedBox(width: 33,),
                  Stack(
                  alignment: Alignment.center,
                    children: [
                      Image.asset("assets/favo.png", scale: 1.8,),
                      Positioned(
                        top: 90,
                        left: 35,
                        child: Image.asset("assets/abelha_animada.png", scale: 9,)
                        ,)
                    ],
                  ),
                  SizedBox(width: 12,),
                  Text("0", textScaler: TextScaler.linear(12),
                    style: TextStyle(color: Colors.orange,
                    shadows: [
                      Shadow(color: Colors.black54, offset: const Offset(4.0, 4.0), blurRadius: 8)
                    ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
