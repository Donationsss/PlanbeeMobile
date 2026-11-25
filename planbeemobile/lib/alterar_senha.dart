import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

import 'data/auth_service.dart';/// Mini página de alteração de senha.
///
/// Traz o mesmo layout das outras telas (logo + fundo amarelo + inputs 350).
/// Exige a nova senha e a confirmação antes de salvar.
class AlterarSenha extends StatefulWidget {
  final String email;

  const AlterarSenha({super.key, required this.email});

  @override
  State<AlterarSenha> createState() => _AlterarSenhaState();
}

class _AlterarSenhaState extends State<AlterarSenha> {
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool passwordVisible = true; // true = senha escondida
  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _trocarSenha() async {
    if (_carregando) return;
    FocusScope.of(context).unfocus();

    final nova = _senhaCtrl.text;
    final confirma = _confirmarCtrl.text;

    if (nova.length < 6) {
      setState(() => _erro = 'A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (nova != confirma) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.trocarSenha(email: widget.email, novaSenha: nova);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Senha alterada com sucesso! Faça login novamente.'),
      ));
      Navigator.popUntil(context, (rota) => rota.isFirst);
    } on AuthException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    } catch (e, st) {
      if (mounted) {
        setState(() => _erro = AuthService.mensagemInesperada(
            'Não foi possível alterar a senha. Tente novamente.', e, st));
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
                    Column(
                      children: [
                        const Text("Alterar senha",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 24)),
                        const SizedBox(height: 6),
                        const SizedBox(
                          width: 350,
                          child: Text(
                            "Escolha uma nova senha para a sua conta.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            controller: _senhaCtrl,
                            obscureText: passwordVisible,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _trocarSenha(),
                            decoration: InputDecoration(
                              labelText: "Nova senha",
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
                              hintText: "Digite a nova senha",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 350,
                          child: TextFormField(
                            controller: _confirmarCtrl,
                            obscureText: passwordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _trocarSenha(),
                            decoration: InputDecoration(
                              labelText: "Confirmar nova senha",
                              helperText: "Digite a nova senha novamente",
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
                              hintText: "Confirme a nova senha",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
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
                      onPressed: _carregando ? null : _trocarSenha,
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
                          : const Text("Trocar senha",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
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
