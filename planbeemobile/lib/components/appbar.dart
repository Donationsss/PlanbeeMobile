import 'package:flutter/material.dart';
import 'package:planbeemobile/components/avatar_usuario.dart';
import 'package:planbeemobile/perfil.dart';

class MainAppBar extends StatefulWidget {
  /// Quando true, o botão de perfil fica desativado (ex.: durante um estudo).
  final bool bloqueado;

  const MainAppBar({super.key, this.bloqueado = false});

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
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
        Text(
          "Planbee",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.bloqueado
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Perfil()),
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Opacity(
                opacity: widget.bloqueado ? 0.35 : 1,
                child: const AvatarUsuario(tamanho: 35, tamanhoIcone: 35),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
