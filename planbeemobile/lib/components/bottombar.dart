import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/estudos.dart';
import 'package:planbeemobile/rotina.dart';

import '../agenda.dart';
import '../home.dart';

class BottomBar extends StatefulWidget {
  /// Quando true, a navegação fica travada (ex.: durante um estudo).
  final bool bloqueado;

  const BottomBar({super.key, this.bloqueado = false});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int paginaAtual = 0;

  @override
  Widget build(BuildContext context) {
    final barra = BottomNavigationBar(
      backgroundColor: Color(0xFFFFDA5E),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: paginaAtual,
      iconSize: 30.0,
      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        if (widget.bloqueado) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(
              content: Text('Finalize o estudo para sair desta tela.'),
            ));
          return;
        }

        setState(() {
          paginaAtual = index;
        });

        // navegação
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Home(),
            ),
          );
        }

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Agenda(),
            ),
          );
        }

        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Rotina(),
            ),
          );
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Estudos(),
            ),
          );
        }
      },

      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled, color: Colors.black),
          label: "",
        ),

        BottomNavigationBarItem(
          icon: Icon(MdiIcons.calendarClock, color: Colors.black),
          label: "",
        ),

        BottomNavigationBarItem(
          icon: Icon(MdiIcons.clockEdit, color: Colors.black),
          label: "",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book, color: Colors.black),
          label: "",
        ),

        BottomNavigationBarItem(
          icon: Icon(MdiIcons.cog, color: Colors.black),
          label: "",
        ),
      ],
    );

    return widget.bloqueado ? Opacity(opacity: 0.4, child: barra) : barra;
  }
}
