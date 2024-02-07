// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordenes App',
      home: Orden(),
    );
  }
}

class Orden extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Órdenes'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('ordenes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data?.docs;

          if (orders == null || orders.isEmpty) {
            return Center(
              child: Text('No hay órdenes disponibles.'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              return InkWell(
                onTap: () {
                  // Handle onTap
                },
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      if (order['imagen'] != null)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(order['imagen']),
                            ),
                          ),
                        ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(order['cliente'] ?? 'Cliente no especificado'),
                            Text('ID Orden: ${order['idOrden'] ?? 'N/A'}'),
                            Text('ID Usuario: ${order['idUsuario'] ?? 'N/A'}'),
                            Text(
                                'Fecha Creación: ${order['fechaCreacion'] ?? 'N/A'}'),
                            Text('Estado: ${order['estado'] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          var result = await showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                EditarOrdenDialog(
                              idOrden: order['idOrden'],
                              idUsuario: order['idUsuario'],
                              fechaCreacion: order['fechaCreacion'],
                              estado: order['estado'],
                              imagen: order['imagen'],
                            ),
                          );

                          if (result != null &&
                              result is Map<String, dynamic>) {
                            // Actualizar la orden en Firebase
                            await FirebaseFirestore.instance
                                .collection('ordenes')
                                .doc(orders[index].id)
                                .update(result);
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          // Implementar la lógica de eliminación
                          await FirebaseFirestore.instance
                              .collection('ordenes')
                              .doc(orders[index].id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await showDialog(
            context: context,
            builder: (BuildContext context) => AgregarOrdenDialog(),
          );

          if (result != null && result is Map<String, dynamic>) {
            // Agregar la nueva orden a Firebase
            await FirebaseFirestore.instance.collection('ordenes').add(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AgregarOrdenDialog extends StatefulWidget {
  @override
  _AgregarOrdenDialogState createState() => _AgregarOrdenDialogState();
}

class _AgregarOrdenDialogState extends State<AgregarOrdenDialog> {
  final TextEditingController idOrdenController = TextEditingController();
  final TextEditingController idUsuarioController = TextEditingController();
  final TextEditingController fechaCreacionController = TextEditingController();
  String estadoValue = 'Pendiente'; // Valor inicial
  String errorText = '';
  File? _imageFile;

  Future<String?> _subirImagen(File imageFile) async {
    try {
      var imagePath = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FirebaseStorage.instance.ref(imagePath).putFile(imageFile);
      return await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Nueva Orden'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: idOrdenController,
            decoration: InputDecoration(labelText: 'ID Orden'),
          ),
          TextField(
            controller: idUsuarioController,
            decoration: InputDecoration(labelText: 'ID Usuario'),
          ),
          TextField(
            controller: fechaCreacionController,
            decoration: InputDecoration(labelText: 'Fecha Creación'),
          ),
          SizedBox(height: 8),
          _imageFile != null
              ? Image.file(
                  _imageFile!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
              : SizedBox(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.getImage(source: ImageSource.camera);

                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: Text('Tomar Foto'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.getImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                    });
                  }
                },
                child: Text('Seleccionar Imagen'),
              ),
            ],
          ),
          DropdownButtonFormField(
            value: estadoValue,
            items: ['Pendiente', 'En Proceso', 'Completado', 'Cancelado']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                estadoValue = newValue ?? 'Pendiente';
              });
            },
            decoration: InputDecoration(labelText: 'Estado'),
          ),
          if (errorText.isNotEmpty)
            Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_validarDatos()) {
              String? imageUrl;
              if (_imageFile != null) {
                imageUrl = await _subirImagen(_imageFile!);
              }

              Navigator.pop(context, {
                'idOrden': idOrdenController.text,
                'idUsuario': idUsuarioController.text,
                'fechaCreacion': fechaCreacionController.text,
                'estado': estadoValue,
                'imagen': imageUrl,
              });
            }
          },
          child: Text('Guardar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancelar'),
        ),
      ],
    );
  }

  bool _validarDatos() {
    if (idOrdenController.text.isEmpty ||
        idUsuarioController.text.isEmpty ||
        fechaCreacionController.text.isEmpty) {
      setState(() {
        errorText = 'Todos los campos son obligatorios';
      });
      return false;
    } else {
      setState(() {
        errorText = '';
      });
      return true;
    }
  }
}

class EditarOrdenDialog extends StatefulWidget {
  final String? idOrden;
  final String? idUsuario;
  final String? fechaCreacion;
  final String? estado;
  final String? imagen;

  EditarOrdenDialog({
    required this.idOrden,
    required this.idUsuario,
    required this.fechaCreacion,
    required this.estado,
    required this.imagen,
  });

  @override
  _EditarOrdenDialogState createState() => _EditarOrdenDialogState();
}

class _EditarOrdenDialogState extends State<EditarOrdenDialog> {
  TextEditingController idOrdenController = TextEditingController();
  TextEditingController idUsuarioController = TextEditingController();
  TextEditingController fechaCreacionController = TextEditingController();
  String estadoValue = 'Pendiente';
  File? _imageFile;
  String? _newImageUrl;

  @override
  void initState() {
    super.initState();
    idOrdenController.text = widget.idOrden ?? '';
    idUsuarioController.text = widget.idUsuario ?? '';
    fechaCreacionController.text = widget.fechaCreacion ?? '';
    estadoValue = widget.estado ?? 'Pendiente';
  }

  Future<String?> _subirImagen(File imageFile) async {
    try {
      var imagePath = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FirebaseStorage.instance.ref(imagePath).putFile(imageFile);
      return await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Orden'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            widget.imagen != null
                ? Image.network(
                    widget.imagen!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : SizedBox(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.getImage(source: ImageSource.camera);

                    if (pickedFile != null) {
                      setState(() {
                        _imageFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Tomar Foto'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final pickedFile =
                        await picker.getImage(source: ImageSource.gallery);

                    if (pickedFile != null) {
                      setState(() {
                        _imageFile = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text('Seleccionar Imagen'),
                ),
              ],
            ),
            TextField(
              controller: idOrdenController,
              decoration: InputDecoration(labelText: 'ID Orden'),
            ),
            TextField(
              controller: idUsuarioController,
              decoration: InputDecoration(labelText: 'ID Usuario'),
            ),
            TextField(
              controller: fechaCreacionController,
              decoration: InputDecoration(labelText: 'Fecha Creación'),
            ),
            DropdownButtonFormField(
              value: estadoValue,
              items: ['Pendiente', 'En Proceso', 'Completado', 'Cancelado']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  estadoValue = newValue ?? 'Pendiente';
                });
              },
              decoration: InputDecoration(labelText: 'Estado'),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_imageFile != null) {
              final newImageUrl = await _subirImagen(_imageFile!);
              setState(() {
                _newImageUrl = newImageUrl;
              });
            }

            Navigator.pop(context, {
              'idOrden': idOrdenController.text,
              'idUsuario': idUsuarioController.text,
              'fechaCreacion': fechaCreacionController.text,
              'estado': estadoValue,
              'imagen': _newImageUrl ?? widget.imagen,
            });
          },
          child: Text('Guardar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancelar'),
        ),
      ],
    );
  }
}
