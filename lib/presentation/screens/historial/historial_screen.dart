import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traductor_voz/presentation/screens/historial/detalle_conversacion_screen.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool seleccionMultiple = false;
  Set<String> seleccionados = {};

  void toggleSeleccion(String id) {
    setState(() {
      if (seleccionados.contains(id)) {
        seleccionados.remove(id);
      } else {
        seleccionados.add(id);
      }
    });
  }

  Future<void> eliminarSeleccionados() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    for (var id in seleccionados) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('conversaciones')
          .doc(id)
          .delete();
    }
    setState(() {
      seleccionados.clear();
      seleccionMultiple = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de conversaciones'),
        actions: [
          if (seleccionMultiple)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: eliminarSeleccionados,
            )
          else
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  seleccionMultiple = true;
                });
              },
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .collection('conversaciones')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No hay conversaciones'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final conv = Conversacion.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );

              return ListTile(
                leading: seleccionMultiple
                    ? Checkbox(
                        value: seleccionados.contains(conv.id),
                        onChanged: (_) => toggleSeleccion(conv.id),
                      )
                    : null,
                title: Text(conv.title),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'eliminar',
                      child: Text('Eliminar'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'eliminar') {
                      FirebaseFirestore.instance
                          .collection('conversaciones')
                          .doc(conv.id)
                          .delete();
                    }
                  },
                ),
                onTap: () {
                  if (seleccionMultiple) {
                    toggleSeleccion(conv.id);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetalleConversacionScreen(conversacion: conv),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
