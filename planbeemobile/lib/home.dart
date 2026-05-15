import 'package:flutter/material.dart';
import 'package:planbeemobile/perfil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  // Coloque esta função antes do "Widget build" ou no final da classe
  Widget _buildDiaSemana(String nome, Color cor) {
    return Column(
      children: [
        Text(nome, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
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
            // --- PARTE DE CIMA: Título ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Semana 1", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_right, size: 60),
              ],
            ),

            SizedBox(height: 20), // Um respiro entre o título e o card

            // --- PARTE DE BAIXO: O Card dos Dias ---
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDiaSemana("Segunda", Colors.green),
                  _buildDiaSemana("Terça", Colors.green),
                  _buildDiaSemana("Quarta", Colors.red),
                  _buildDiaSemana("Quinta", Colors.green),
                  _buildDiaSemana("Sexta", Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
