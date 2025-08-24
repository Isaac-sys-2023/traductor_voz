import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traductor_voz/presentation/screens/historial/detalle_conversacion_screen.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';
import 'package:provider/provider.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  bool seleccionMultiple = false;
  Set<String> seleccionados = {};
  List<Conversacion> conversaciones = [];

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
    final batch = FirebaseFirestore.instance.batch();

    for (var id in seleccionados) {
      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('conversaciones')
          .doc(id);
      batch.delete(docRef);
    }

    await batch.commit();
    setState(() {
      seleccionados.clear();
      seleccionMultiple = false;
    });
  }

  Future<void> eliminarConversacion(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('conversaciones')
        .doc(id)
        .delete();
  }

  void seleccionarTodo() {
    setState(() {
      for (var conv in conversaciones) {
        seleccionados.add(conv.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          seleccionMultiple
              ? 'Seleccionados: ${seleccionados.length}'
              : 'Historial de conversaciones',
        ),
        actions: [
          if (seleccionMultiple)
            Row(
              children: [
                // ElevatedButton(
                //   onPressed: seleccionarTodo,
                //   child: Text('Selec. todo'),
                // ),
                IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: () {
                    if (conversaciones.length == seleccionados.length) {
                      setState(() {
                        seleccionados.clear();
                      });
                    } else {
                      seleccionarTodo();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    if (seleccionados.isEmpty) return;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'Eliminar ${seleccionados.length} conversaciones',
                        ),
                        content: const Text(
                          '¿Estás seguro de eliminar estas conversaciones?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              eliminarSeleccionados();
                              Navigator.pop(context);
                            },
                            child: const Text('Si'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      seleccionMultiple = false;
                      seleccionados.clear();
                    });
                  },
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                setState(() {
                  seleccionMultiple = true;
                });
              },
            ),
        ],
      ),

      body: Column(
        children: [
          if (!isConnected) const SinConexion(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .collection('conversaciones')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay conversaciones'));
                }

                final docs = snapshot.data!.docs;
                conversaciones = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Conversacion.fromFirestore(data, doc.id);
                }).toList();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    // Verifica que la conversión funcione correctamente
                    final conv = Conversacion.fromFirestore(data, doc.id);

                    return ListTile(
                      leading: seleccionMultiple
                          ? Checkbox(
                              value: seleccionados.contains(conv.id),
                              onChanged: (_) => toggleSeleccion(conv.id),
                            )
                          : null,
                      title: Text(conv.title),
                      subtitle: Text(
                        '${conv.messages.length} mensaje(s)',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: seleccionMultiple
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Eliminar conversación'),
                                    content: const Text(
                                      '¿Estás seguro de eliminar esta conversación?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          eliminarConversacion(conv.id);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  ),
                                );
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
                      onLongPress: () {
                        setState(() {
                          seleccionMultiple = true;
                          toggleSeleccion(conv.id);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
