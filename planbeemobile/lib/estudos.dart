import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:planbeemobile/components/appbar.dart';

import 'components/bottombar.dart';

class Estudos extends StatefulWidget {
  const Estudos({super.key});

  @override
  State<Estudos> createState() => _EstudosState();
}

class _EstudosState extends State<Estudos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFDA5E),
        title: MainAppBar(),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFFF9CF),
      body: Center(
      child: Container(
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black26,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDA5E),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          children: [
            Container(
              width: 360,
              height: 190,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEB8A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        DropdownButtonFormField(items: [], onChanged: (value) {  },),
                        DropdownButtonFormField(items: [], onChanged: (value) {  },),
                        TextField(
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 20),

                  // LADO DIREITO
                  Expanded(
                    child: Column(
                      spacing: 10,
                      children: [
                        Text(
                          "Pomodoro",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),

                        Text(
                          "25:00",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),

                        SizedBox(
                          width: 120,
                          height: 20,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFDA5E),
                                padding: EdgeInsets.all(0)
                            ),
                            child: const Text(
                              "Estudar",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 120,
                          height: 25,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFDA5E),
                              padding: EdgeInsets.all(0)
                            ),
                            child: const Text(
                              "Resetar",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                  fontSize: 12
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: 120,
                          height: 20,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFFFDA5E),
                                padding: EdgeInsets.all(0)
                            ),
                            child: const Text(
                              "Salvar",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ),

            const SizedBox(height: 16),

            Expanded(
              child: Container(
                width: 360,
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEB8A),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text("Área dos Resumos"),
              ),
            ),
          ],
        ),
      ),
    ),
    ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
