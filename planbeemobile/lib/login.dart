import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFDA5E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Image.asset("assets/logo.png", width: 100, height: 100,),
               Text("Planbee", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),)
             ], 
            )
          ],
        ),
      )
    );
  }
}
