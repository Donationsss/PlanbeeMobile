import 'package:flutter/material.dart';
import 'package:planbeemobile/data/auth_service.dart';

/// Avatar circular do usuário.
///
/// Se o usuário escolheu uma foto no Perfil, mostra a imagem recortada em
/// círculo; caso contrário, mostra o ícone padrão de usuário.
class AvatarUsuario extends StatelessWidget {
  final double tamanho;
  final double tamanhoIcone;
  final Color fundo;
  final bool sombra;

  const AvatarUsuario({
    super.key,
    this.tamanho = 35,
    this.tamanhoIcone = 35,
    this.fundo = Colors.transparent,
    this.sombra = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Usuario?>(
      valueListenable: AuthService.usuarioListenable,
      builder: (context, u, _) {
        final bytes = u?.fotoBytes;
        return Container(
          width: tamanho,
          height: tamanho,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: fundo,
            shape: BoxShape.circle,
            boxShadow: sombra
                ? const [
                    BoxShadow(
                        color: Colors.black38,
                        blurRadius: 4,
                        offset: Offset(0, 3)),
                  ]
                : null,
          ),
          child: bytes == null
              ? Icon(Icons.person, size: tamanhoIcone, color: Colors.black)
              : Image.memory(
                  bytes,
                  width: tamanho,
                  height: tamanho,
                  fit: BoxFit.cover,
                ),
        );
      },
    );
  }
}
