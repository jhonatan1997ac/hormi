import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

Future<List> getUsuario() async {
  List usuarios = []; // Cambiado el nombre a 'usuarios'
  CollectionReference collectionReferenceUsuario = db.collection('usuario');

  QuerySnapshot queryUsuario = await collectionReferenceUsuario.get();
  for (var documento in queryUsuario.docs) {
    final Map<String, dynamic> data = documento.data() as Map<String, dynamic>;
    final usuario = {
      "nombre": data['nombre'],
      "uid": documento.id,
    };
    usuarios.add(
        usuario); // Cambiado de 'usuario.add(data)' a 'usuarios.add(usuario)'
  }
  return usuarios; // Cambiado de 'usuario' a 'usuarios'
}

Future<void> addUsuario(String nombre) async {
  try {
    // Lógica para agregar el usuario a Firestore
    await db.collection("usuario").add({"nombre": nombre});
    print('Usuario agregado exitosamente: $nombre');
  } catch (e) {
    print('Error al agregar usuario: $e');
  }
}

Future<Map<String, dynamic>> editUsuario(String uid, String nuevoNombre) async {
  await FirebaseFirestore.instance
      .collection('usuario')
      .doc(uid)
      .update({'nombre': nuevoNombre});

  // Obtener los datos actualizados después de la edición
  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('usuario').doc(uid).get();

  // Devolver los datos actualizados
  return snapshot.data() as Map<String, dynamic>;
}

Future<void> deleteUsuario(String uid) async {
  await db.collection("usuario").doc(uid).delete();
}
