import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUsuario() async {
  List usuarios = [];
  CollectionReference collectionReferenceUsuario = db.collection('usuario');

  QuerySnapshot queryUsuario = await collectionReferenceUsuario.get();
  for (var documento in queryUsuario.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    final usuario = {
      "nombre": data['nombre'],
      "uid": documento.id,
    };
    usuarios.add(usuario);
  }
  return usuarios;
}

Future<void> addUsuario(String nombre) async {
  try {
    await db.collection("usuario").add({"nombre": nombre});
    if (kDebugMode) {
      print('Usuario agregado exitosamente: $nombre');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error al agregar usuario: $e');
    }
  }
}

Future<Map<String, dynamic>> editUsuario(String uid, String nuevoNombre) async {
  await FirebaseFirestore.instance
      .collection('usuario')
      .doc(uid)
      .update({'nombre': nuevoNombre});

  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('usuario').doc(uid).get();

  return snapshot.data() as Map<String, dynamic>;
}

Future<void> deleteUsuario(String uid) async {
  await db.collection("usuario").doc(uid).delete();
}
