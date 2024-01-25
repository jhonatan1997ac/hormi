// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, unused_local_variable

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProductoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> agregarProducto(Producto nuevoProducto, String imageUrl) async {
    try {
      // Buscar si el producto ya existe en la base de datos
      var existingProduct = await _firestore
          .collection('disponibilidadproducto')
          .where('nombre', isEqualTo: nuevoProducto.nombre)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        var existingDoc = existingProduct.docs.first;
        var existingCantidad = existingDoc['cantidad'] as int;
        var nuevaCantidad = existingCantidad + nuevoProducto.cantidad;
        var existingPrecio = existingDoc['precio'] as double;

        // Check if the quality is the same
        var existingCalidad = existingDoc['calidad'] as String;
        if (existingCalidad == nuevoProducto.calidad) {
          // Update the price if the quality is the same
          await _firestore
              .collection('disponibilidadproducto')
              .doc(existingDoc.id)
              .update({
            'cantidad': nuevaCantidad,
            'precio': nuevoProducto.precio,
            'calidad': nuevoProducto.calidad,
          });
        } else {
          // Handle the case where the quality is different
          print('Error: Quality is different.');
        }
      } else {
        // Add a new product if it doesn't exist
        await _firestore.collection('disponibilidadproducto').add({
          'nombre': nuevoProducto.nombre,
          'precio': nuevoProducto.precio,
          'cantidad': nuevoProducto.cantidad,
          'disponible': nuevoProducto.disponible,
          'imagen': imageUrl,
          'calidad': nuevoProducto.calidad,
        });
      }

      if (kDebugMode) {
        print('Producto agregado correctamente a la base de datos.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar el producto: $e');
      }
    }
  }

  Future<String?> subirImagen(File? imagen) async {
    try {
      if (imagen != null) {
        Reference storageReference = _storage.ref().child(
            'imagenes_productos/${DateTime.now().millisecondsSinceEpoch}');
        UploadTask uploadTask = storageReference.putFile(imagen);
        await uploadTask.whenComplete(() => null);
        String imageUrl = await storageReference.getDownloadURL();
        return imageUrl;
      }
      return null; // Retorna null si no hay imagen
    } catch (e) {
      print('Error al subir la imagen: $e');
      throw Exception('Error al subir la imagen');
    }
  }
}

class Producto {
  String nombre;
  double precio;
  int cantidad;
  bool disponible;
  File? imagen;
  String calidad;

  Producto({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.disponible,
    this.imagen,
    required this.calidad,
  });

  bool get estaDisponible => disponible;
}

class AgregarProducto extends StatefulWidget {
  const AgregarProducto({Key? key}) : super(key: key);

  @override
  _AgregarProductoState createState() => _AgregarProductoState();
}

class _AgregarProductoState extends State<AgregarProducto> {
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  bool _disponible = true;
  String _selectedProducto = 'Adoquin clasico peatonal sin color';
  String _selectedCalidad = 'Calidad adoquin resistencia 300';
  File? _selectedImage;

  final List<String> _productos = [
    'Adoquin clasico peatonal sin color',
    'Adoquin clasico peatonal con color',
    'Adoquin clasico vehicular sin color',
    'Adoquin clasico vehicular con color',
    'Adoquin jaboncillo peatonal sin color',
    'Adoquin jaboncillo peatonal con color',
    'Adoquin jaboncillo vehicular sin color',
    'Adoquin jaboncillo vehicular con color',
    'Adoquin paleta peatonal sin color',
    'Adoquin paleta peatonal con color',
    'Adoquin paleta vehicular sin color',
    'Adoquin paleta vehicular con color',
    'Bloque de 10cm alivianado',
    'Bloque de 10cm estructural',
    'Bloque de 15cm alivianado',
    'Bloque de 15cm estructural',
    'Bloque de 20cm alivianado',
    'Bloque de 20cm estructural',
    'Postes de alambrado 1.60m',
    'Postes de alambrado 2m',
    'Bloque de anclaje',
    'Tapas para canaleta',
  ];
  final List<String> _calidad = [
    'Calidad adoquin resistencia 300',
    'Calidad adoquin resistencia 350',
    'Calidad adoquin resistencia 400',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Nombre:'),
                const SizedBox(width: 16.0),
                DropdownButton<String>(
                  value: _selectedProducto,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProducto = newValue!;
                    });
                  },
                  items:
                      _productos.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(labelText: 'Precio'),
              controller: _precioController,
              keyboardType: TextInputType.number,
            ),
            if (double.tryParse(_precioController.text) != null &&
                double.parse(_precioController.text) <= 0)
              const Text(
                'El precio debe ser mayor a 0',
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              decoration: InputDecoration(labelText: 'Cantidad'),
              controller: _cantidadController,
              keyboardType: TextInputType.number,
            ),
            if (int.tryParse(_cantidadController.text) != null &&
                int.parse(_cantidadController.text) < 1)
              const Text(
                'La cantidad debe ser mayor o igual a 1',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Calidad:'),
                const SizedBox(width: 16.0),
                DropdownButton<String>(
                  value: _selectedCalidad,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCalidad = newValue!;
                    });
                  },
                  items: _calidad.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Disponible:'),
                Switch(
                  value: _disponible,
                  onChanged: (value) {
                    setState(() {
                      _disponible = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_selectedImage != null) Image.file(_selectedImage!),
            ElevatedButton(
              onPressed: _seleccionarImagen,
              child: const Text('Seleccionar Imagen'),
            ),
            const SizedBox(height: 16.0),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_selectedImage != null &&
                      double.tryParse(_precioController.text) != null &&
                      double.parse(_precioController.text) > 0 &&
                      int.tryParse(_cantidadController.text) != null &&
                      int.parse(_cantidadController.text) >= 1) {
                    await _agregarProducto();
                    Navigator.pushNamed(context, '/disponibilidadproducto');
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text(
                              'Debe seleccionar una imagen y completar los campos correctamente.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Agregar Producto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _agregarProducto() async {
    final nombre = _selectedProducto;
    final precio = double.parse(_precioController.text);
    final cantidad = int.parse(_cantidadController.text);

    final productoService = ProductoService();
    final imageUrl = await productoService.subirImagen(_selectedImage);

    final nuevoProducto = Producto(
      nombre: nombre,
      precio: precio,
      cantidad: cantidad,
      disponible: _disponible,
      imagen: _selectedImage,
      calidad: _selectedCalidad,
    );

    await productoService.agregarProducto(nuevoProducto, imageUrl!);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Aplicación',
      home: AgregarProducto(),
    );
  }
}

void main() {
  runApp(MyApp());
}
