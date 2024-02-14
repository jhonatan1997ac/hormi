// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      var existingProduct = await _firestore
          .collection('disponibilidadproducto')
          .where('nombre', isEqualTo: nuevoProducto.nombre)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        var existingDoc = existingProduct.docs.first;
        var existingCantidad = existingDoc['cantidad'] as int;
        var nuevaCantidad = existingCantidad + nuevoProducto.cantidad;
        var existingCalidad = existingDoc['calidad'] as String;

        if (existingCalidad == nuevoProducto.calidad) {
          await _firestore
              .collection('disponibilidadproducto')
              .doc(existingDoc.id)
              .update({
            'cantidad': nuevaCantidad,
            'precio': nuevoProducto.precio,
            'calidad': nuevoProducto.calidad,
          });
        } else {
          print('Error: Quality is different.');
        }
      } else {
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error al agregar el producto: $e');
        print(stackTrace);
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
      return null;
    } catch (e, stackTrace) {
      print('Error al subir la imagen: $e');
      print(stackTrace);
      return null;
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

  static fromSnapshot(QueryDocumentSnapshot<Object?> doc) {}
}

class ProductosAdministrador extends StatefulWidget {
  const ProductosAdministrador({Key? key}) : super(key: key);

  @override
  _ProductosAdministradorState createState() => _ProductosAdministradorState();
}

class _ProductosAdministradorState extends State<ProductosAdministrador> {
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
    'Calidad bloques 2MPA',
    'Calidad bloques 4MPA',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agregar Producto',
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
            size: 50.0,
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
              Color.fromARGB(
                  255, 55, 111, 139), // Color del inicio del degradado
              Color.fromARGB(255, 165, 160, 160),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    const Text(
                      'Nombre:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    DropdownButton<String>(
                      value: _selectedProducto,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedProducto = newValue!;
                        });
                      },
                      items: _productos
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                color: Colors.white, // Fondo blanco para los datos
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        labelStyle: TextStyle(
                            color: Colors
                                .black), // Color de texto para la etiqueta
                      ),
                      controller: _precioController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    if (_precioController.text.isNotEmpty &&
                        double.parse(_precioController.text) <= 0)
                      const Text(
                        'El precio debe ser mayor a 0',
                        style: TextStyle(color: Colors.red),
                      ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Cantidad',
                        labelStyle: TextStyle(
                            color: Colors
                                .black), // Color de texto para la etiqueta
                      ),
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                    ),
                    if (_cantidadController.text.isNotEmpty &&
                        int.parse(_cantidadController.text) < 1)
                      const Text(
                        'La cantidad debe ser mayor o igual a 1',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Text(
                          'Calidad:',
                          style: TextStyle(
                              color: Colors
                                  .black), // Color de texto para el título
                        ),
                        const SizedBox(width: 16.0),
                        DropdownButton<String>(
                          value: _selectedCalidad,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCalidad = newValue!;
                            });
                          },
                          items: _calidad
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        const Text(
                          'Disponible:',
                          style: TextStyle(
                              color: Colors
                                  .black), // Color de texto para el título
                        ),
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
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  width: 150.0,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
              ElevatedButton(
                onPressed: _seleccionarImagen,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 16.0),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedImage != null &&
                      _precioController.text.isNotEmpty &&
                      _cantidadController.text.isNotEmpty) {
                    await _agregarProducto();
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
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Agregar Producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Administrador(),
      ),
    );
  }

  Future<void> _agregarProducto() async {
    final nombre = _selectedProducto;
    final precio = double.parse(_precioController.text);
    final cantidad = int.parse(_cantidadController.text);

    final productoService = ProductoService();
    final imageUrl = await productoService.subirImagen(_selectedImage);

    if (imageUrl != null) {
      final nuevoProducto = Producto(
        nombre: nombre,
        precio: precio,
        cantidad: cantidad,
        disponible: _disponible,
        imagen: _selectedImage,
        calidad: _selectedCalidad,
      );

      await productoService.agregarProducto(nuevoProducto, imageUrl);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Éxito'),
            content: const Text('Producto agregado correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                      context, '/disponibilidadproductoadministrador');
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Error al subir la imagen.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Aplicación',
      debugShowCheckedModeBanner: false,
      home: ProductosAdministrador(),
    );
  }
}

void main() {
  runApp(MyApp());
}
