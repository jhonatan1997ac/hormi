import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario extends StatefulWidget {
  const Usuario({Key? key}) : super(key: key);

  @override
  _UsuarioState createState() => _UsuarioState();
}

class _UsuarioState extends State<Usuario> {
  // ignore: unused_element
  Future<List<UserCredential>> _getUsers() async {
    try {
      // Lee el contenido del archivo credentials.json
      String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/credentials/credentials.json');
      Map<String, dynamic> credentials = json.decode(jsonString);

      // Inicializa Firebase si aún no se ha inicializado
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: credentials['api_key'],
            authDomain: credentials['auth_domain'],
            databaseURL: credentials['database_url'],
            projectId: credentials['project_id'],
            storageBucket: credentials['storage_bucket'],
            messagingSenderId: credentials['messaging_sender_id'],
            appId: credentials['app_id'],
            measurementId: credentials['measurement_id'],
          ),
        );
      }

      // Iniciar sesión anónima (puedes cambiar esto según tus necesidades)
      UserCredential userCredential =
          await FirebaseAuth.instance.signInAnonymously();

      return [userCredential];
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Error al obtener la lista de usuarios: $error');
        print(stackTrace);
      }

      String errorMessage = 'Error al obtener la lista de usuarios';

      if (error is FirebaseException) {
        errorMessage = 'Firebase Error: ${error.message}';
        // Puedes agregar más lógica para manejar diferentes tipos de errores de Firebase aquí
      }

      // Mostrar un mensaje de error en caso de fallo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );

      // Puedes manejar el error de alguna manera apropiada
      return [];
    }
  }

  Future<void> _showUsersListDialog(BuildContext context) async {
    try {
      // Obtener la lista de usuarios desde Firestore
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('usuarios').get();

      // Construir el diálogo para mostrar la lista de usuarios
      // ignore: use_build_context_synchronously
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lista de Usuarios'),
            content: SingleChildScrollView(
              child: ListBody(
                children: querySnapshot.docs
                    .map((QueryDocumentSnapshot<Map<String, dynamic>>
                            document) =>
                        ListTile(
                          title: Text('Usuario ID: ${document.id}'),
                          subtitle: Text('Email: ${document['email']}'),
                        ))
                    .toList(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );

      // Actualizar la interfaz de usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuarios obtenidos exitosamente'),
        ),
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('Error al obtener la lista de usuarios: $error');
        print(stackTrace);
      }

      String errorMessage = 'Error al obtener la lista de usuarios';

      if (error is FirebaseException) {
        errorMessage = 'Firebase Error: ${error.message}';
        // Puedes agregar más lógica para manejar diferentes tipos de errores de Firebase aquí
      }

      // Mostrar un mensaje de error en caso de fallo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios Autenticados'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            if (kDebugMode) {
              print('Error in auth state: ${snapshot.error}');
            }
            return Text('Error: ${snapshot.error}');
          } else {
            User? user = snapshot.data;

            if (user == null) {
              return const Text('No hay usuarios autenticados.');
            } else {
              return ListView(
                children: [
                  ListTile(
                    title: Text('Usuario ID: ${user.uid}'),
                    subtitle: Text('Email: ${user.email}'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _showUsersListDialog(context);
                    },
                    child: const Text('Obtener Lista de Usuarios'),
                  ),
                ],
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Puedes agregar lógica para realizar operaciones adicionales
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      home: Usuario(),
    ),
  );
}
