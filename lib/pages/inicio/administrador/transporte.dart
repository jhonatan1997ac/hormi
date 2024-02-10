import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class Transporte extends StatefulWidget {
  const Transporte({Key? key}) : super(key: key);

  @override
  _TransporteState createState() => _TransporteState();
}

class _TransporteState extends State<Transporte> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  TextEditingController idController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController contactoController = TextEditingController();
  TextEditingController imagenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transporte App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Datos de Transportes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            const Icon(Icons.directions_bus),
            const SizedBox(width: 20),
            const Text(
              'Información sobre Transportes',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildTransportesTable(),
            ),
            Center(
              child: SizedBox(
                width: 450,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _mostrarDialogoAgregarTransporte(context);
                  },
                  child: const Text(
                    'Agregar Transporte',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportesTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transporte')
          .orderBy('idtransporte')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var transportes = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Contacto')),
              DataColumn(label: Text('Imagen')),
              DataColumn(label: Text('Acciones')),
            ],
            rows: transportes.map((transporte) {
              var id = transporte['idtransporte'];
              var nombre = transporte['nombre'];
              var contacto = transporte['contacto'];
              var imagen = transporte['imagen'];

              return DataRow(cells: [
                DataCell(Text(id)),
                DataCell(Text(nombre)),
                DataCell(Text(contacto)),
                DataCell(
                  Image.network(imagen, width: 50, height: 50),
                ),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _mostrarDialogoEditarTransporte(context, transporte);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _eliminarTransporte(transporte.id);
                      },
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoAgregarTransporte(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Transporte'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.directions_bus),
                const SizedBox(width: 8),
                const Text(
                  'Información sobre Transportes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: idController,
                  decoration:
                      const InputDecoration(labelText: 'ID del Transporte'),
                ),
                TextField(
                  controller: nombreController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del Transporte'),
                ),
                TextField(
                  controller: contactoController,
                  decoration: const InputDecoration(
                      labelText: 'Contacto del Transporte'),
                ),
                ElevatedButton(
                  onPressed: _tomarFoto,
                  child: const Text('Tomar Foto'),
                ),
              ],
            ),
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
                _subirImagenYAgregarTransporte();
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        imagenController.text = foto.path;
      });
    }
  }

  Future<void> _subirImagenYAgregarTransporte() async {
    File imageFile = File(imagenController.text);

    try {
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('transporte')
          .child('$imageName.jpg');
      await ref.putFile(imageFile);

      String imageUrl = await ref.getDownloadURL();

      await agregarTransporte(imageUrl);

      if (kDebugMode) {
        print('Transporte agregado correctamente');
      }
      idController.clear();
      nombreController.clear();
      contactoController.clear();
      imagenController.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar transporte: $e');
      }
    }
  }

  Future<void> agregarTransporte(String imageUrl) async {
    CollectionReference transporteCollection =
        _firestore.collection('transporte');

    Map<String, dynamic> nuevoTransporte = {
      'idtransporte': idController.text,
      'nombre': nombreController.text,
      'contacto': contactoController.text,
      'imagen': imageUrl,
    };

    try {
      await transporteCollection.add(nuevoTransporte);
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar transporte: $e');
      }
    }
  }

  Future<void> _mostrarDialogoEditarTransporte(
      BuildContext context, DocumentSnapshot transporte) async {
    idController.text = transporte['idtransporte'];
    nombreController.text = transporte['nombre'];
    contactoController.text = transporte['contacto'];
    imagenController.text = transporte['imagen'];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Transporte'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.directions_bus),
                const SizedBox(width: 8),
                const Text(
                  'Información sobre Transportes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: idController,
                  decoration:
                      const InputDecoration(labelText: 'ID del Transporte'),
                ),
                TextField(
                  controller: nombreController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del Transporte'),
                ),
                TextField(
                  controller: contactoController,
                  decoration: const InputDecoration(
                      labelText: 'Contacto del Transporte'),
                ),
                ElevatedButton(
                  onPressed: _tomarFoto,
                  child: const Text('Tomar Foto'),
                ),
              ],
            ),
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
                _actualizarTransporte(transporte.id);
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarTransporte(String transporteId) async {
    try {
      await _firestore.collection('transporte').doc(transporteId).delete();
      if (kDebugMode) {
        print('Transporte eliminado correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar transporte: $e');
      }
    }
  }

  Future<void> _actualizarTransporte(String transporteId) async {
    try {
      await _firestore.collection('transporte').doc(transporteId).update({
        'idtransporte': idController.text,
        'nombre': nombreController.text,
        'contacto': contactoController.text,
        'imagen': imagenController.text,
      });
      if (kDebugMode) {
        print('Transporte actualizado correctamente');
      }
      idController.clear();
      nombreController.clear();
      contactoController.clear();
      imagenController.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar transporte: $e');
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Transporte();
  }
}
