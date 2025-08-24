import 'package:flutter/material.dart';

class SinConexion extends StatelessWidget {
  final String? mensaje;
  final Color? colorFondo;
  final Color? colorTexto;
  final double? fontSize;

  const SinConexion({
    Key? key,
    this.mensaje,
    this.colorFondo,
    this.colorTexto,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorFondo ?? Colors.red,
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            mensaje ?? 'Sin conexión',
            style: TextStyle(
              color: colorTexto ?? Colors.white,
              fontSize: fontSize ?? 16,
            ),
          ),
        ],
      ),
    );
  }
}
