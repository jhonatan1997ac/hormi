// ignore_for_file: library_private_types_in_public_api

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: VendedorAdministrador(),
  ));
}

class VendedorAdministrador extends StatefulWidget {
  const VendedorAdministrador({Key? key}) : super(key: key);

  @override
  _VendedorAdministradorState createState() => _VendedorAdministradorState();
}

class _VendedorAdministradorState extends State<VendedorAdministrador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestionar Vendedor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Administrador()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 55, 111, 139),
              Color.fromARGB(255, 165, 160, 160),
            ],
          ),
        ),
        child: StreamBuilder<User?>(
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
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                                child: ListView.builder(
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    var userData = users[index].data();
                                    return Container(
                                      margin: const EdgeInsets.all(8.0),
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          'Email: ${userData['email']}',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Email: ${userData['email']}',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              'Rol: ${userData['rool']}',
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.black),
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
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.black),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(users[index].id)
                                                    .delete();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: FloatingActionButton.extended(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/agregarvendedor');
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Agregar Vendedor'),
                                backgroundColor: Colors.black,
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
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: roolController,
                decoration: const InputDecoration(labelText: 'Nuevo Rol'),
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
