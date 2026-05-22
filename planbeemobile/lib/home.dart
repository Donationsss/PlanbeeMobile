import 'package:flutter/material.dart';
import 'package:planbeemobile/perfil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentIndex = 0;

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
        backgroundColor: Colors.amberAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset("assets/logo.png", height: 50, width: 50,),
            Text("Planbee", style: TextStyle(fontSize: 25),),
            IconButton(
                onPressed: (){
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const Perfil()),
                  );
                } ,
                icon: const Icon(Icons.person, size: 35,),
            ),
          ],
        ),
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
            SizedBox(height: 20), // Um respiro entre o título e o card

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
                gradient: LinearGradient(colors: [Colors.orange, Colors. orangeAccent, Colors.yellow]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDiaSemana("Segnd", Colors.white,),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Terça", Colors.white),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Quarta", Colors.white),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Quinta", Colors.white),
                  VerticalDivider(color: Colors.white, thickness: 2.5),
                  _buildDiaSemana("Sexta", Colors.white),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: 0,
        iconSize: 30.0,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined), label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.timelapse_outlined), label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book), label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add), label: "",
          ),
        ],
      ),
    );
  }
}
