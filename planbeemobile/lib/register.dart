import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'data/auth_service.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _emailCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool passwordVisible = true; // true = senha escondida
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nomeCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_carregando) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.cadastrar(
        nome: _nomeCtrl.text,
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
        iniciarSessao: false, // quem se registra precisa fazer login
      );
      if (!mounted) return;
      // Conta criada: vai para o login (e não direto para o app).
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Conta criada! Faça login para continuar.'),
      ));
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
        (_) => false,
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (e, st) {
      if (mounted) {
        setState(() => _erro = AuthService.mensagemInesperada(
            'Não foi possível criar a conta. Tente novamente.', e, st));
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
                  spacing: 30,
                  children: [
                    SizedBox(
                      width: 350,
                      child: TextFormField(
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
                      child: TextFormField(
                        controller: _nomeCtrl,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: "Usuário",
                          suffixIcon: Icon(MdiIcons.account),
                          hintText: "Digite seu nome de usuário",
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 350,
                      child: TextFormField(
                        controller: _senhaCtrl,
                        obscureText: passwordVisible,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _registrar(),
                        decoration: InputDecoration(
                          labelText: "Senha",
                          helperText: "Mínimo de 6 caracteres",
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
                    if (_erro != null)
                      SizedBox(
                        width: 350,
                        child: Text(
                          _erro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Color(0xFFB00020),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ElevatedButton(
                      onPressed: _carregando ? null : _registrar,
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
                          : const Text("Registrar",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Já tem uma conta? Entrar",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
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
