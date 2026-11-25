import 'package:flutter/material.dart';
import 'package:planbeemobile/components/avatar_usuario.dart';
import 'package:planbeemobile/perfil.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          "assets/logo.png",
          height: 50,
          width: 50,
        ),
        const Text(
          "Planbee",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Perfil()),
            );
          },
          tooltip: 'Perfil',
          icon: const AvatarUsuario(tamanho: 35, tamanhoIcone: 35),
        ),
      ],
    );
  }
}
