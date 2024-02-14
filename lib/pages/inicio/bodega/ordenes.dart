import 'dart:io';

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        title: const Text(
          'Órdenes',
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
              MaterialPageRoute(builder: (context) => const Bodeguero()),
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
      body: OrdenList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await showDialog(
            context: context,
            builder: (BuildContext context) => AgregarOrdenDialog(),
          );

          if (result != null && result is Map<String, dynamic>) {
            await FirebaseFirestore.instance.collection('ordenes').add(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class OrdenList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('ordenes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data?.docs;

          if (orders == null || orders.isEmpty) {
            return const Center(
              child: Text('No hay órdenes disponibles.',
                  style: TextStyle(color: Colors.white)),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
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
                              Text(
                                  order['cliente'] ?? 'Cliente no especificado',
                                  style: TextStyle(color: Colors.black)),
                              Text('ID Orden: ${order['idOrden'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black)),
                              Text('ID Usuario: ${order['idUsuario'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black)),
                              Text(
                                  'Fecha Creación: ${order['fechaCreacion'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black)),
                              Text('Estado: ${order['estado'] ?? 'N/A'}',
                                  style: TextStyle(color: Colors.black)),
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
                                id: orders[index].id,
                                idUsuario: order['idUsuario'],
                                idOrden: order['idOrden'],
                                fechaCreacion: order['fechaCreacion'],
                                estado: order['estado'],
                                imagen: order['imagen'],
                              ),
                            );

                            if (result != null &&
                                result is Map<String, dynamic>) {
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
                            await FirebaseFirestore.instance
                                .collection('ordenes')
                                .doc(orders[index].id)
                                .delete();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AgregarOrdenDialog extends StatefulWidget {
  @override
  _AgregarOrdenDialogState createState() => _AgregarOrdenDialogState();
}

class _AgregarOrdenDialogState extends State<AgregarOrdenDialog> {
  final TextEditingController idUsuarioController = TextEditingController();
  final TextEditingController idOrdenController = TextEditingController();
  final TextEditingController fechaCreacionController = TextEditingController();
  String estadoValue = 'Pendiente'; // Initial value
  String errorText = '';
  File? _imageFile;

  Future<String?> _uploadImage(File imageFile) async {
    try {
      var imagePath = 'ordenes/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FirebaseStorage.instance.ref(imagePath).putFile(imageFile);
      return await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<bool> _checkIfIdOrdenExists(String idOrden) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('ordenes')
        .where('idOrden', isEqualTo: idOrden)
        .get();

    return querySnapshot.docs.isNotEmpty;
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
            decoration: InputDecoration(labelText: 'ID Orden *'),
          ),
          TextField(
            controller: idUsuarioController,
            decoration: InputDecoration(labelText: 'ID Usuario *'),
          ),
          TextField(
            controller: fechaCreacionController,
            decoration: InputDecoration(labelText: 'Fecha Creación *'),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                setState(() {
                  fechaCreacionController.text =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                });
              }
            },
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
            decoration: InputDecoration(labelText: 'Estado *'),
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
            if (_validateData()) {
              final idOrden = idOrdenController.text;
              final idOrdenExists = await _checkIfIdOrdenExists(idOrden);

              if (idOrdenExists) {
                setState(() {
                  errorText = 'El ID de la orden ya existe';
                });
              } else {
                String? imageUrl;
                if (_imageFile != null) {
                  imageUrl = await _uploadImage(_imageFile!);
                }

                await FirebaseFirestore.instance.collection('ordenes').add({
                  'idUsuario': idUsuarioController.text,
                  'idOrden': idOrden,
                  'fechaCreacion': fechaCreacionController.text,
                  'estado': estadoValue,
                  'imagen': imageUrl,
                });

                Navigator.pop(context);
              }
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

  bool _validateData() {
    if (idUsuarioController.text.isEmpty ||
        idOrdenController.text.isEmpty ||
        fechaCreacionController.text.isEmpty ||
        _imageFile == null) {
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
  final String id;
  final String? idUsuario;
  final String? idOrden;
  final String? fechaCreacion;
  final String? estado;
  final String? imagen;

  EditarOrdenDialog({
    required this.id,
    required this.idUsuario,
    required this.idOrden,
    required this.fechaCreacion,
    required this.estado,
    required this.imagen,
  });

  @override
  _EditarOrdenDialogState createState() => _EditarOrdenDialogState();
}

class _EditarOrdenDialogState extends State<EditarOrdenDialog> {
  TextEditingController idUsuarioController = TextEditingController();
  TextEditingController idOrdenController = TextEditingController();
  TextEditingController fechaCreacionController = TextEditingController();
  String estadoValue = 'Pendiente';
  File? _imageFile;
  String? _newImageUrl;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    idOrdenController.text = widget.idOrden ?? '';
    idUsuarioController.text = widget.idUsuario ?? '';
    fechaCreacionController.text = widget.fechaCreacion ?? '';
    estadoValue = widget.estado ?? 'Pendiente';
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      var imagePath = 'ordenes/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await FirebaseStorage.instance.ref(imagePath).putFile(imageFile);
      return await FirebaseStorage.instance.ref(imagePath).getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Orden'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idOrdenController,
              decoration: InputDecoration(labelText: 'ID Orden *'),
            ),
            if (widget.imagen != null)
              Image.network(
                widget.imagen!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
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
                  child: const Text('Tomar Foto '),
                ),
                const SizedBox(width: 8),
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
                  child: const Text('Seleccionar Imagen '),
                ),
              ],
            ),
            TextField(
              controller: idUsuarioController,
              decoration: InputDecoration(labelText: 'ID Usuario *'),
            ),
            TextField(
              controller: fechaCreacionController,
              decoration: InputDecoration(labelText: 'Fecha Creación *'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    fechaCreacionController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
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
              decoration: InputDecoration(labelText: 'Estado *'),
            ),
            if (errorText.isNotEmpty)
              Text(
                errorText,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (_imageFile != null) {
              final newImageUrl = await _uploadImage(_imageFile!);
              setState(() {
                _newImageUrl = newImageUrl;
              });
            }

            if (_validateData()) {
              Navigator.pop(context, {
                'idUsuario': idUsuarioController.text,
                'idOrden': idOrdenController.text,
                'fechaCreacion': fechaCreacionController.text,
                'estado': estadoValue,
                'imagen': _newImageUrl ?? widget.imagen,
              });
            }
          },
          child: const Text('Guardar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

  bool _validateData() {
    if (idUsuarioController.text.isEmpty ||
        idOrdenController.text.isEmpty ||
        fechaCreacionController.text.isEmpty ||
        _imageFile == null) {
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
