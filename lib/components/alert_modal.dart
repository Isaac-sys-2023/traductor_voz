import 'package:flutter/material.dart';

class ModalAlerta extends StatelessWidget {
  final String titulo;
  final String contenido;
  final String textoBoton;
  final VoidCallback? onPressed;
  final IconData? icono;

  const ModalAlerta({
    Key? key,
    required this.titulo,
    required this.contenido,
    this.textoBoton = "OK",
    this.onPressed,
    this.icono,
  }) : super(key: key);

  static void mostrar({
    required BuildContext context,
    required String titulo,
    required String contenido,
    String textoBoton = "OK",
    VoidCallback? onPressed,
    IconData? icono,
  }) {
    showDialog(
      context: context,
      builder: (_) => ModalAlerta(
        titulo: titulo,
        contenido: contenido,
        textoBoton: textoBoton,
        onPressed: onPressed,
        icono: icono,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icono != null ? Icon(icono) : null,
      title: Text(titulo),
      content: Text(contenido),
      actions: [
        TextButton(
          onPressed: onPressed ?? () => Navigator.pop(context),
          child: Text(textoBoton),
        ),
      ],
    );
  }
}
