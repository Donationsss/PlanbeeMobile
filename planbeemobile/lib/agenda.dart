import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/components/appbar.dart';


import 'components/bottombar.dart';

class Agenda extends StatefulWidget {
  const Agenda({super.key});

  @override
  State<Agenda> createState() => _AgendaState();
}

class Dia {
  final String dia;

  Dia({
    required this.dia,
  });
}

final List<Dia> Dias = [
  Dia(dia: "1"),
];

class _AgendaState extends State<Agenda> {

  void _mostrarDetalhes(Dia dias) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dias.dia,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDA5E),
        title: MainAppBar(),
        centerTitle: true,
      ),

      backgroundColor: const Color(0xFFFFF9CF),
      body: Center( // Centraliza tudo na tela
        child: Container(
            width: 400,
            height: 400,
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFF2D2D2D),
              borderRadius: BorderRadius.circular(23),
            ),

            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFFDA5E),
                borderRadius: BorderRadius.circular(23),
              ),
              child: GridView.count(
                padding: EdgeInsets.all(8),
                crossAxisCount: 7,
                childAspectRatio: .6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 15,
                children: List.generate(Dias.length, (index) {
                  final dias = Dias[index];

                  return InkWell(
                    onTap: () {
                      _mostrarDetalhes(dias);
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAlias, // corta qualquer overflow
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dias.dia,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ),
            )
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
