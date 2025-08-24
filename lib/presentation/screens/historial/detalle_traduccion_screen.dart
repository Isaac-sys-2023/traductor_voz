// import 'package:flutter/material.dart';
// import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';
// import 'package:provider/provider.dart';
// import 'package:traductor_voz/providers/connectivity_provider.dart';
// import 'package:traductor_voz/components/no_connection.dart';

// class DetalleConversacionScreen extends StatelessWidget {
//   final Conversacion conversacion;
//   const DetalleConversacionScreen({Key? key, required this.conversacion})
//     : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isConnected = context.watch<ConnectivityProvider>().isConnected;
//     return Scaffold(
//       appBar: AppBar(title: Text(conversacion.title)),
//       body: Column(
//         children: [
//           if (isConnected == false) SinConexion(),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(8),
//               itemCount: conversacion.messages.length,
//               itemBuilder: (context, index) {
//                 final msg = conversacion.messages[index];
//                 return Align();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';
import 'package:provider/provider.dart';
import 'package:traductor_voz/providers/connectivity_provider.dart';
import 'package:traductor_voz/components/no_connection.dart';

class DetalleUniConversacionScreen extends StatefulWidget {
  final Conversacion conversacion;
  const DetalleUniConversacionScreen({Key? key, required this.conversacion})
    : super(key: key);

  @override
  State<DetalleUniConversacionScreen> createState() =>
      _DetalleUniConversacionScreenState();
}

class _DetalleUniConversacionScreenState
    extends State<DetalleUniConversacionScreen> {
  final ScrollController _firstScrollController = ScrollController();
  final ScrollController _secondScrollController = ScrollController();
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();

    // Configurar sincronización de scroll
    _firstScrollController.addListener(() {
      if (!_isScrolling) {
        _isScrolling = true;
        _secondScrollController.jumpTo(_firstScrollController.offset);
        _isScrolling = false;
      }
    });

    _secondScrollController.addListener(() {
      if (!_isScrolling) {
        _isScrolling = true;
        _firstScrollController.jumpTo(_secondScrollController.offset);
        _isScrolling = false;
      }
    });
  }

  @override
  void dispose() {
    _firstScrollController.dispose();
    _secondScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityProvider>().isConnected;

    return Scaffold(
      appBar: AppBar(title: Text(widget.conversacion.title)),
      body: Column(
        children: [
          if (isConnected == false) SinConexion(),
          Expanded(
            child: Column(
              children: [
                // Texto original - ocupa la mitad superior
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Scrollbar(
                      controller: _firstScrollController,
                      child: SingleChildScrollView(
                        controller: _firstScrollController,
                        child: Text(
                          widget.conversacion.messages[0].originalText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),

                // Texto traducido - ocupa la mitad inferior
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Scrollbar(
                      controller: _secondScrollController,
                      child: SingleChildScrollView(
                        controller: _secondScrollController,
                        child: Text(
                          widget.conversacion.messages[0].translatedText,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
