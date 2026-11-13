import 'package:flutter/material.dart';
import 'package:planbeemobile/login.dart';

import 'data/auth_service.dart';
import 'home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Abre o banco e, se já havia alguém logado, restaura a sessão.
  final logado = await AuthService.restaurarSessao();
  runApp(MyApp(iniciarLogado: logado));
}

class MyApp extends StatelessWidget {
  final bool iniciarLogado;

  const MyApp({super.key, this.iniciarLogado = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planbee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: iniciarLogado ? const Home() : const Login(),
    );
  }
}
