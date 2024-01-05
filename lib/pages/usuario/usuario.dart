import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Usuario extends StatelessWidget {
  const Usuario({Key? key});

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
            print('Error in auth state: ${snapshot.error}');
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
