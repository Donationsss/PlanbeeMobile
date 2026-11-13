import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/forgotPassword.dart';
import 'package:planbeemobile/home.dart';
import 'package:planbeemobile/register.dart';

import 'data/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool passwordVisible = true; // true = senha escondida
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (_carregando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.entrar(email: _emailCtrl.text, senha: _senhaCtrl.text);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (e, st) {
      if (mounted) {
        setState(() => _erro = AuthService.mensagemInesperada(
            'Não foi possível entrar. Tente novamente.', e, st));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFDA5E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
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
                  const Text(
                    "Planbee",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Column(
                      spacing: 30,
                      children: [
                        SizedBox(
                          width: 350,
                          child: TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
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
                            controller: _senhaCtrl,
                            obscureText: passwordVisible,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _entrar(),
                            decoration: InputDecoration(
                              labelText: "Senha",
                              suffixIcon: IconButton(
                                icon: Icon(passwordVisible
                                    ? MdiIcons.eyeOff
                                    : MdiIcons.eye),
                                onPressed: () {
                                  setState(() {
                                    passwordVisible = !passwordVisible;
                                  });
                                },
                              ),
                              hintText: "Digite sua senha",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 370,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Forgotpassword()));
                              },
                              child: const Text(
                                "Esqueceu sua senha?",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Register()));
                              },
                              child: const Text(
                                "Não tem uma conta? Registre-se!",
                                style:
                                    TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_erro != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: 350,
                          child: Text(
                            _erro!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFFB00020),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _carregando ? null : _entrar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFCB20),
                        elevation: 10,
                        fixedSize: const Size(150, 50),
                      ),
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.black),
                            )
                          : const Text("Login",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
