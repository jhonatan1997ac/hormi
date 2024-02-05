import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MaterialApp(
    home: VendedorAdministrador(),
  ));
}

class VendedorAdministrador extends StatefulWidget {
  const VendedorAdministrador({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VendedorAdministradorState createState() => _VendedorAdministradorState();
}

class _VendedorAdministradorState extends State<VendedorAdministrador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Vendedor'),
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            User? user = snapshot.data;

            if (user == null) {
              return const Text('No hay usuarios autenticados.');
            } else {
              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('rool', isEqualTo: 'vendedor')
                    .snapshots(),
                builder: (context, usersSnapshot) {
                  if (usersSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (usersSnapshot.hasError) {
                    return Text('Error: ${usersSnapshot.error}');
                  } else {
                    var users = usersSnapshot.data?.docs;

                    if (users == null || users.isEmpty) {
                      return const Text(
                          'No se encontraron usuarios vendedores.');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                var userData = users[index].data();
                                return ListTile(
                                  title: Text('Usuario ID: ${users[index].id}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Email: ${userData['email']}'),
                                      Text('Rol: ${userData['rool']}'),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          _showEditDialog(
                                            context,
                                            users[index].id,
                                            userData['email'],
                                            userData['rool'],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(users[index].id)
                                              .delete();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/agregarvendedor');
                              },
                              icon: Icon(Icons.add),
                              label: Text('Agregar Vendedor'),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String userId,
    String currentEmail,
    String currentRool,
  ) {
    TextEditingController emailController = TextEditingController();
    TextEditingController roolController = TextEditingController();

    emailController.text = currentEmail;
    roolController.text = currentRool;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Nuevo Email'),
              ),
              TextField(
                controller: roolController,
                decoration: const InputDecoration(labelText: 'Nuevo Rol'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .update({
                  'email': emailController.text,
                  'rool': roolController.text,
                });

                Navigator.of(context).pop();
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }
}
