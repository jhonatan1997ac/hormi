import 'dart:io';

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MaterialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarMaterial(String nombre, String descripcion,
      String cantidad, String imagenURL) async {
    try {
      var existingMaterial = await _firestore
          .collection('disponibilidadmaterial')
          .where('nombre', isEqualTo: nombre)
          .get();

      if (existingMaterial.docs.isNotEmpty) {
        print('Material existente. Puedes implementar lógica específica.');
      } else {
        if (_esValido(nombre, descripcion, cantidad)) {
          await _firestore.collection('disponibilidadmaterial').add({
            'nombre': nombre,
            'descripcion': descripcion,
            'cantidad': int.parse(cantidad), // Convierte a entero
            'imagenURL': imagenURL, // Agrega la URL de la imagen
          });

          print('Material agregado correctamente a la base de datos.');
        } else {
          print('Datos no válidos. No se ha agregado el material.');
        }
      }
    } catch (e) {
      print('Error al agregar el material: $e');
    }
  }

  bool _esValido(String nombre, String descripcion, String cantidad) {
    return cantidad.isNotEmpty && nombre.isNotEmpty && descripcion.isNotEmpty;
  }
}

class AgregarMaterial extends StatefulWidget {
  const AgregarMaterial({Key? key}) : super(key: key);

  @override
  _AgregarMaterialState createState() => _AgregarMaterialState();
}

class _AgregarMaterialState extends State<AgregarMaterial> {
  String _selectedMaterial = 'Arena';
  String _selectedDescripcion = 'Volqueta';
  String _selectedCantidad = '1';
  final ImagePicker _picker = ImagePicker();
  File? _imagenTomada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Material',
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Escoja el material:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  color: const Color.fromARGB(255, 148, 164, 179),
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedMaterial,
                    dropdownColor:
                        Colors.white, // Fondo blanco del menú desplegable
                    style: TextStyle(color: Colors.black), // Texto negro
                    items: [
                      'Arena',
                      'Piedra',
                      'Ripio',
                      'Piedra triturada',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMaterial = newValue ?? '';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Escoja el modo:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  color: const Color.fromARGB(255, 148, 164, 179),
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedDescripcion,
                    items: [
                      'Volqueta',
                      'Mamut',
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDescripcion = newValue ?? '';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Escoja la cantidad:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  color: const Color.fromARGB(255, 148, 164, 179),
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: _selectedCantidad,
                    items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCantidad = newValue ?? '';
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Tomar foto:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                Container(
                  height: 200,
                  width: 200,
                  color: const Color.fromARGB(255, 142, 166, 189),
                  child: InkWell(
                    onTap: _tomarFoto,
                    child: _imagenTomada != null
                        ? Image.file(_imagenTomada!)
                        : const Icon(Icons.camera_alt,
                            color: Colors.black), // Icono en negro
                  ),
                ),
                const SizedBox(height: 16.0),
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _agregarMaterial();
                    },
                    child: const Text('Agregar Material'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _imagenTomada = File(foto.path);
      });
    }
  }

  Future<void> _agregarMaterial() async {
    final nombre = _selectedMaterial;
    final descripcion = _selectedDescripcion;
    final cantidad = _selectedCantidad;

    if (_imagenTomada != null) {
      final String imagenURL =
          await _subirImagenAFirebaseStorage(_imagenTomada!);

      final materialService = MaterialService();
      await materialService.agregarMaterial(
          nombre, descripcion, cantidad, imagenURL);

      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/disponibilidadmaterial');
    } else {
      print('Por favor, primero tome una foto.');
    }
  }

  Future<String> _subirImagenAFirebaseStorage(File imagen) async {
    try {
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('material')
          .child('material_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final firebase_storage.UploadTask uploadTask = ref.putFile(imagen);
      final firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      final String url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir la imagen a Firebase Storage: $e');
      }
      return '';
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Aplicación',
      home: AgregarMaterial(),
    );
  }
}

void main() {
  runApp(MyApp());
}
