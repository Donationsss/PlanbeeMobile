import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/forgotPassword.dart';
import 'package:planbeemobile/register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool passwordVisible = false;
  @override
  void initState() {
    super.initState();
    passwordVisible = true;
  }

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
                        SizedBox(
                          width: 350,
                          child: TextField(
                            obscureText: passwordVisible,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible ? MdiIcons.eyeOff : MdiIcons.eye),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                              hintText: "Digite sua senha",
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
                          TextButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Forgotpassword()));
                          }, child: Text("Esqueceu sua senha?", style: TextStyle(fontSize: 12, color: Colors.black),)),
                          TextButton(onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                          }, child: Text("Não tem uma conta? Registre-se!", style: TextStyle(fontSize: 12, color: Colors.black),))
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),

                    // trocar o link para a Home() dps que fazer o merge
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
                      child: Text("Login",
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
