import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const MaterialApp(
    home: Departamento(),
  ));
}

class Departamento extends StatefulWidget {
  const Departamento({Key? key}) : super(key: key);

  @override
  _DepartamentoState createState() => _DepartamentoState();
}

class _DepartamentoState extends State<Departamento> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Departamentos'),
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
                    .collection('departamento')
                    .snapshots(),
                builder: (context, departamentosSnapshot) {
                  if (departamentosSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (departamentosSnapshot.hasError) {
                    return Text('Error: ${departamentosSnapshot.error}');
                  } else {
                    var departamentos = departamentosSnapshot.data?.docs;

                    if (departamentos == null || departamentos.isEmpty) {
                      return const Text('No se encontraron departamentos.');
                    } else {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: departamentos.length,
                              itemBuilder: (context, index) {
                                var departamentoData =
                                    departamentos[index].data();
                                return ListTile(
                                  title: Text(
                                      'Departamento ID: ${departamentos[index].id}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Nombre: ${departamentoData['nombre']}'),
                                      Text(
                                          'Ubicación: ${departamentoData['ubicacion']}'),
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
                                            departamentos[index].id,
                                            departamentoData['nombre'],
                                            departamentoData['ubicacion'],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('departamento')
                                              .doc(departamentos[index].id)
                                              .delete();
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                                    context, '/agregardepartamento');
                              },
                              icon: Icon(Icons.add),
                              label: Text('Agregar Departamento'),
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
    String departamentoId,
    String currentNombre,
    String currentUbicacion,
  ) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController ubicacionController = TextEditingController();

    nombreController.text = currentNombre;
    ubicacionController.text = currentUbicacion;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Departamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nuevo Nombre'),
              ),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(labelText: 'Nueva Ubicación'),
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
                    .collection('departamento')
                    .doc(departamentoId)
                    .update({
                  'nombre': nombreController.text,
                  'ubicacion': ubicacionController.text,
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
