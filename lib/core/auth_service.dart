import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:traductor_voz/data/local_database.dart';
import 'package:traductor_voz/presentation/screens/historial/domain/conversation.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear usuario con email y password
  // Future<User?> registerWithEmail(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result.user;
  //   } catch (e) {
  //     print("Error al registrar: $e");
  //     return null;
  //   }
  // }
  Future<User?> registerWithEmail(
    String email,
    String password,
    String name,
    String language,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nombre': name,
          'email': email,
          'idioma': language,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Error al registrar: $e");
      return null;
    }
  }

  // Iniciar sesión con email y password
  // Future<User?> loginWithEmail(String email, String password) async {
  //   try {
  //     UserCredential result = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return result.user;
  //   } catch (e) {
  //     print("Error al iniciar sesión: $e");
  //     return null;
  //   }
  // }
  Future<Map<String, dynamic>?> loginWithEmailAndGetData(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('usuarios')
            .doc(user.uid)
            .get();

        try {
          final snapshot = await _firestore
              .collection('usuarios')
              .doc(user.uid)
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

        return {'user': user, 'idioma': doc['idioma'], 'nombre': doc['nombre']};
      }
    } catch (e) {
      print("Error al iniciar sesión: $e");
    }
    return null;
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream para escuchar cambios de sesión
  Stream<User?> get userChanges => _auth.authStateChanges();
}
