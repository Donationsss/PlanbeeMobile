import 'package:flutter/material.dart';
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
        IconButton(
          onPressed: widget.bloqueado
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Perfil()),
                  );
                },
          icon: Icon(
            Icons.person,
            size: 35,
            color: widget.bloqueado ? Colors.black26 : Colors.black,
          ),
        ),
      ],
    );
  }
}
