import 'package:flutter/material.dart';
import 'package:planbeemobile/components/appbar.dart';

import 'data/auth_service.dart';
import 'login.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  Future<void> _sair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFEB8A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta?'),
        content: const Text('Seus dados ficam salvos e estarão aqui quando você entrar de novo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: const Color(0xFFFFA53D)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await AuthService.sair();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = AuthService.usuario;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFDA5E),
        title: const MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDA5E),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black38, blurRadius: 4, offset: Offset(0, 3)),
                  ],
                ),
                child: const Icon(Icons.person, size: 70),
              ),
              const SizedBox(height: 20),
              Text(
                u?.nome ?? '',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(u?.email ?? '', style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: () => _sair(context),
                icon: const Icon(Icons.logout, color: Colors.black),
                label: const Text('Sair',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFCB20),
                  elevation: 6,
                  fixedSize: const Size(160, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
