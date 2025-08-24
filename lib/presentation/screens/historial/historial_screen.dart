// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:traductor_voz/data/local_database.dart';
// import 'package:traductor_voz/presentation/screens/historial/detalle_conversacion_screen.dart';
// import 'package:traductor_voz/presentation/screens/historial/detalle_traduccion_screen.dart';
// import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';
// import 'package:provider/provider.dart';
// import 'package:traductor_voz/providers/connectivity_provider.dart';
// import 'package:traductor_voz/components/no_connection.dart';

// class HistorialScreen extends StatefulWidget {
//   const HistorialScreen({Key? key}) : super(key: key);

//   @override
//   State<HistorialScreen> createState() => _HistorialScreenState();
// }

// class _HistorialScreenState extends State<HistorialScreen> {
//   bool seleccionMultiple = false;
//   Set<String> seleccionados = {};
//   List<Conversacion> conversaciones = [];

//   void toggleSeleccion(String id) {
//     setState(() {
//       if (seleccionados.contains(id)) {
//         seleccionados.remove(id);
//       } else {
//         seleccionados.add(id);
//       }
//     });
//   }

//   Future<void> eliminarSeleccionados() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     final batch = FirebaseFirestore.instance.batch();

//     for (var id in seleccionados) {
//       final docRef = FirebaseFirestore.instance
//           .collection('usuarios')
//           .doc(uid)
//           .collection('conversaciones')
//           .doc(id);
//       batch.delete(docRef);
//     }

//     await batch.commit();
//     setState(() {
//       seleccionados.clear();
//       seleccionMultiple = false;
//     });
//   }

//   Future<void> eliminarConversacion(String id) async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     await FirebaseFirestore.instance
//         .collection('usuarios')
//         .doc(uid)
//         .collection('conversaciones')
//         .doc(id)
//         .delete();
//   }

//   void seleccionarTodo() {
//     setState(() {
//       for (var conv in conversaciones) {
//         seleccionados.add(conv.id);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isConnected = context.watch<ConnectivityProvider>().isConnected;
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           seleccionMultiple
//               ? 'Seleccionados: ${seleccionados.length}'
//               : 'Historial de conversaciones',
//         ),
//         actions: [
//           if (seleccionMultiple)
//             Row(
//               children: [
//                 // ElevatedButton(
//                 //   onPressed: seleccionarTodo,
//                 //   child: Text('Selec. todo'),
//                 // ),
//                 IconButton(
//                   icon: const Icon(Icons.done_all),
//                   onPressed: () {
//                     if (conversaciones.length == seleccionados.length) {
//                       setState(() {
//                         seleccionados.clear();
//                       });
//                     } else {
//                       seleccionarTodo();
//                     }
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete),
//                   onPressed: () {
//                     if (seleccionados.isEmpty) return;
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text(
//                           'Eliminar ${seleccionados.length} conversaciones',
//                         ),
//                         content: const Text(
//                           '¿Estás seguro de eliminar estas conversaciones?',
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: const Text('No'),
//                           ),
//                           TextButton(
//                             onPressed: () {
//                               eliminarSeleccionados();
//                               Navigator.pop(context);
//                             },
//                             child: const Text('Si'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () {
//                     setState(() {
//                       seleccionMultiple = false;
//                       seleccionados.clear();
//                     });
//                   },
//                 ),
//               ],
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.settings),
//               onPressed: () {
//                 setState(() {
//                   seleccionMultiple = true;
//                 });
//               },
//             ),
//         ],
//       ),

//       // body: Column(
//       //   children: [
//       //     if (!isConnected) const SinConexion(),

//       //     Expanded(
//       //       child: StreamBuilder<QuerySnapshot>(
//       //         stream: FirebaseFirestore.instance
//       //             .collection('usuarios')
//       //             .doc(uid)
//       //             .collection('conversaciones')
//       //             .orderBy('timestamp', descending: true)
//       //             .snapshots(),
//       //         builder: (context, snapshot) {
//       //           if (snapshot.hasError) {
//       //             return Center(child: Text('Error: ${snapshot.error}'));
//       //           }

//       //           if (snapshot.connectionState == ConnectionState.waiting) {
//       //             return const Center(child: CircularProgressIndicator());
//       //           }

//       //           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//       //             return const Center(child: Text('No hay conversaciones'));
//       //           }

//       //           final docs = snapshot.data!.docs;
//       //           conversaciones = docs.map((doc) {
//       //             final data = doc.data() as Map<String, dynamic>;
//       //             return Conversacion.fromFirestore(data, doc.id);
//       //           }).toList();

//       //           return ListView.builder(
//       //             itemCount: docs.length,
//       //             itemBuilder: (context, index) {
//       //               final doc = docs[index];
//       //               final data = doc.data() as Map<String, dynamic>;

//       //               // Verifica que la conversión funcione correctamente
//       //               final conv = Conversacion.fromFirestore(data, doc.id);

//       //               return ListTile(
//       //                 leading: seleccionMultiple
//       //                     ? Checkbox(
//       //                         value: seleccionados.contains(conv.id),
//       //                         onChanged: (_) => toggleSeleccion(conv.id),
//       //                       )
//       //                     : null,
//       //                 title: Text(conv.title),
//       //                 subtitle: Text(
//       //                   '${conv.messages.length} mensaje(s) / ${conv.double_via ? "Doble vía" : "Unidireccional"}',
//       //                   style: const TextStyle(fontSize: 12),
//       //                 ),
//       //                 trailing: seleccionMultiple
//       //                     ? null
//       //                     : IconButton(
//       //                         icon: const Icon(Icons.delete_outline, size: 20),
//       //                         onPressed: () {
//       //                           showDialog(
//       //                             context: context,
//       //                             builder: (context) => AlertDialog(
//       //                               title: const Text('Eliminar conversación'),
//       //                               content: const Text(
//       //                                 '¿Estás seguro de eliminar esta conversación?',
//       //                               ),
//       //                               actions: [
//       //                                 TextButton(
//       //                                   onPressed: () => Navigator.pop(context),
//       //                                   child: const Text('Cancelar'),
//       //                                 ),
//       //                                 TextButton(
//       //                                   onPressed: () {
//       //                                     eliminarConversacion(conv.id);
//       //                                     Navigator.pop(context);
//       //                                   },
//       //                                   child: const Text('Eliminar'),
//       //                                 ),
//       //                               ],
//       //                             ),
//       //                           );
//       //                         },
//       //                       ),
//       //                 onTap: () {
//       //                   if (seleccionMultiple) {
//       //                     toggleSeleccion(conv.id);
//       //                   } else {
//       //                     Navigator.push(
//       //                       context,
//       //                       MaterialPageRoute(
//       //                         builder: (_) => conv.double_via
//       //                             ? DetalleConversacionScreen(
//       //                                 conversacion: conv,
//       //                               )
//       //                             : DetalleUniConversacionScreen(
//       //                                 conversacion: conv,
//       //                               ),
//       //                       ),
//       //                     );
//       //                   }
//       //                 },
//       //                 onLongPress: () {
//       //                   setState(() {
//       //                     seleccionMultiple = true;
//       //                     toggleSeleccion(conv.id);
//       //                   });
//       //                 },
//       //               );
//       //             },
//       //           );
//       //         },
//       //       ),
//       //     ),
//       //   ],
//       // ),
//       body: Column(
//         children: [
//           if (!isConnected) const SinConexion(),

//           Expanded(
//             child: isConnected
//                 ? StreamBuilder<QuerySnapshot>(
//                     stream: FirebaseFirestore.instance
//                         .collection('usuarios')
//                         .doc(uid)
//                         .collection('conversaciones')
//                         .orderBy('timestamp', descending: true)
//                         .snapshots(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasError) {
//                         return Center(child: Text('Error: ${snapshot.error}'));
//                       }

//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }

//                       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                         return const Center(
//                           child: Text('No hay conversaciones'),
//                         );
//                       }

//                       final docs = snapshot.data!.docs;
//                       conversaciones = docs.map((doc) {
//                         final data = doc.data() as Map<String, dynamic>;
//                         return Conversacion.fromFirestore(data, doc.id);
//                       }).toList();

//                       return ListView.builder(
//                         itemCount: docs.length,
//                         itemBuilder: (context, index) {
//                           final doc = docs[index];
//                           final data = doc.data() as Map<String, dynamic>;

//                           // Verifica que la conversión funcione correctamente
//                           final conv = Conversacion.fromFirestore(data, doc.id);

//                           return ListTile(
//                             leading: seleccionMultiple
//                                 ? Checkbox(
//                                     value: seleccionados.contains(conv.id),
//                                     onChanged: (_) => toggleSeleccion(conv.id),
//                                   )
//                                 : null,
//                             title: Text(conv.title),
//                             subtitle: Text(
//                               '${conv.messages.length} mensaje(s) / ${conv.double_via ? "Doble vía" : "Unidireccional"}',
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                             trailing: seleccionMultiple
//                                 ? null
//                                 : IconButton(
//                                     icon: const Icon(
//                                       Icons.delete_outline,
//                                       size: 20,
//                                     ),
//                                     onPressed: () {
//                                       showDialog(
//                                         context: context,
//                                         builder: (context) => AlertDialog(
//                                           title: const Text(
//                                             'Eliminar conversación',
//                                           ),
//                                           content: const Text(
//                                             '¿Estás seguro de eliminar esta conversación?',
//                                           ),
//                                           actions: [
//                                             TextButton(
//                                               onPressed: () =>
//                                                   Navigator.pop(context),
//                                               child: const Text('Cancelar'),
//                                             ),
//                                             TextButton(
//                                               onPressed: () {
//                                                 eliminarConversacion(conv.id);
//                                                 Navigator.pop(context);
//                                               },
//                                               child: const Text('Eliminar'),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                             onTap: () {
//                               if (seleccionMultiple) {
//                                 toggleSeleccion(conv.id);
//                               } else {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => conv.double_via
//                                         ? DetalleConversacionScreen(
//                                             conversacion: conv,
//                                           )
//                                         : DetalleUniConversacionScreen(
//                                             conversacion: conv,
//                                           ),
//                                   ),
//                                 );
//                               }
//                             },
//                             onLongPress: () {
//                               setState(() {
//                                 seleccionMultiple = true;
//                                 toggleSeleccion(conv.id);
//                               });
//                             },
//                           );
//                         },
//                       );
//                     },
//                   )
//                 : FutureBuilder<List<Conversacion>>(
//                     future: LocalDatabase.getConversaciones(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return const Center(
//                           child: Text('No hay conversaciones offline'),
//                         );
//                       }

//                       final convs = snapshot.data!;
//                       conversaciones = convs;

//                       return ListView.builder(
//                         itemCount: convs.length,
//                         itemBuilder: (context, index) {
//                           final conv = convs[index];
//                           return ListTile(
//                             leading: seleccionMultiple
//                                 ? Checkbox(
//                                     value: seleccionados.contains(conv.id),
//                                     onChanged: (_) => toggleSeleccion(conv.id),
//                                   )
//                                 : null,
//                             title: Text(conv.title),
//                             subtitle: Text(
//                               '${conv.messages.length} mensaje(s) / ${conv.double_via ? "Doble vía" : "Unidireccional"}',
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                             onTap: () {
//                               if (seleccionMultiple) {
//                                 toggleSeleccion(conv.id);
//                               } else {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => conv.double_via
//                                         ? DetalleConversacionScreen(
//                                             conversacion: conv,
//                                           )
//                                         : DetalleUniConversacionScreen(
//                                             conversacion: conv,
//                                           ),
//                                   ),
//                                 );
//                               }
//                             },
//                           );
//                         },
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:traductor_voz/data/local_database.dart';
import 'package:traductor_voz/presentation/screens/historial/detalle_conversacion_screen.dart';
import 'package:traductor_voz/presentation/screens/historial/detalle_traduccion_screen.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';
import 'package:provider/provider.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';
import 'package:traductor_voz/components/alert_modal.dart';

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

  Future<void> eliminarSeleccionados(bool isConnected) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (isConnected) {
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
    }

    // Siempre eliminar localmente
    for (var id in seleccionados) {
      await LocalDatabase.deleteConversacion(id);
    }

    setState(() {
      seleccionados.clear();
      seleccionMultiple = false;
    });
  }

  Future<void> eliminarConversacion(String id, bool isConnected) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    if (isConnected) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('conversaciones')
          .doc(id)
          .delete();
    }

    await LocalDatabase.deleteConversacion(id);
  }

  void seleccionarTodo() {
    setState(() {
      for (var conv in conversaciones) {
        seleccionados.add(conv.id);
      }
    });
  }

  /// Guardar las conversaciones de Firestore en SQLite para offline
  Future<void> syncFirestoreToSQLite() async {
    final isConnected = context
        .read<ConnectivityProvider>()
        .isConnected; // revisar estado
    if (!isConnected) return;

    final uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('conversaciones')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final conversacion = Conversacion.fromFirestore(data, doc.id);
        await LocalDatabase.saveConversacion(conversacion);
      }
    } catch (e) {
      print("Error sincronizando conversaciones offline: $e");
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Sincronizar al abrir la pantalla si hay internet
    if (isConnected) syncFirestoreToSQLite();

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
                    if (isConnected) {
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
                                eliminarSeleccionados(isConnected);
                                Navigator.pop(context);
                              },
                              child: const Text('Si'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ModalAlerta.mostrar(
                        context: context,
                        titulo: "Sin conexión",
                        contenido:
                            "No puedes eliminar conversaciones sin internet.",
                        textoBoton: "OK",
                        icono: Icons.wifi_off,
                      );
                    }
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
            child: isConnected
                ? StreamBuilder<QuerySnapshot>(
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
                        return const Center(
                          child: Text('No hay conversaciones'),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      conversaciones = docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final conv = Conversacion.fromFirestore(data, doc.id);
                        // Guardar automáticamente en SQLite
                        LocalDatabase.saveConversacion(conv);
                        return conv;
                      }).toList();

                      return ListView.builder(
                        itemCount: conversaciones.length,
                        itemBuilder: (context, index) {
                          final conv = conversaciones[index];
                          return ListTile(
                            leading: seleccionMultiple
                                ? Checkbox(
                                    value: seleccionados.contains(conv.id),
                                    onChanged: (_) => toggleSeleccion(conv.id),
                                  )
                                : null,
                            title: Text(conv.title),
                            subtitle: Text(
                              '${conv.messages.length} mensaje(s) / ${conv.double_via ? "Doble vía" : "Unidireccional"}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: seleccionMultiple
                                ? null
                                : IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Eliminar conversación',
                                          ),
                                          content: const Text(
                                            '¿Estás seguro de eliminar esta conversación?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                eliminarConversacion(
                                                  conv.id,
                                                  isConnected,
                                                );
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
                                    builder: (_) => conv.double_via
                                        ? DetalleConversacionScreen(
                                            conversacion: conv,
                                          )
                                        : DetalleUniConversacionScreen(
                                            conversacion: conv,
                                          ),
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
                  )
                : FutureBuilder<List<Conversacion>>(
                    future: LocalDatabase.getConversaciones(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text('No hay conversaciones offline'),
                        );
                      }

                      final convs = snapshot.data!;
                      conversaciones = convs;

                      return ListView.builder(
                        itemCount: convs.length,
                        itemBuilder: (context, index) {
                          final conv = convs[index];
                          return ListTile(
                            leading: seleccionMultiple
                                ? Checkbox(
                                    value: seleccionados.contains(conv.id),
                                    onChanged: (_) => toggleSeleccion(conv.id),
                                  )
                                : null,
                            title: Text(conv.title),
                            subtitle: Text(
                              '${conv.messages.length} mensaje(s) / ${conv.double_via ? "Doble vía" : "Unidireccional"}\nGuardada el: ${conv.timestamp != null ? _formatDate(conv.timestamp!) : "Fecha desconocida"}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              if (seleccionMultiple) {
                                toggleSeleccion(conv.id);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => conv.double_via
                                        ? DetalleConversacionScreen(
                                            conversacion: conv,
                                          )
                                        : DetalleUniConversacionScreen(
                                            conversacion: conv,
                                          ),
                                  ),
                                );
                              }
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
