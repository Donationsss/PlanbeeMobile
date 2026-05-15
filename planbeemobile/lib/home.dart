import 'package:flutter/material.dart';
import 'package:planbeemobile/perfil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Row(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
        centerTitle: true,

      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Column(

      ),
    );
  }
}
