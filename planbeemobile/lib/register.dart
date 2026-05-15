import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
              ),
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  spacing: 30,
                  children: [
                    SizedBox(
                      width: 350,
                      child:
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Email",
                          suffixIcon: Icon(Icons.mail),
                          hintText: "Digite seu email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child:
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Usuário",
                          suffixIcon: Icon(MdiIcons.account),
                          hintText: "Digite seu nome de usuário",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child:
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Senha",
                          suffixIcon: Icon(MdiIcons.eyeOff),
                          hintText: "Digite sua senha",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                    },style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFCB20),
                      elevation: 10,
                      fixedSize: Size(150, 50),

                    ), child: Text("Registrar", style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold)),)
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
