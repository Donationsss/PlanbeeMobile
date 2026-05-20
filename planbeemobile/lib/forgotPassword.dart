import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/register.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
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
                  Image.asset(
                    "assets/logo.png",
                    width: 100,
                    height: 100,
                  ),
                  Text(
                    "Planbee",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Column(
                      spacing: 30,
                      children: [
                        Text("Recuperação de senha", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
                        SizedBox(
                          width: 350,
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email",
                              suffixIcon: Icon(Icons.mail),
                              hintText: "Digite seu email",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Register()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFCB20),
                        elevation: 10,
                        fixedSize: Size(150, 50),
                      ),
                      child: Text("Enviar código",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
