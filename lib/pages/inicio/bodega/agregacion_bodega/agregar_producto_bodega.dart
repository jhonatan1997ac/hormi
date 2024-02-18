// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
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
    }
    return null;
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                color: Color.fromARGB(255, 137, 197, 145),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_box, color: Colors.black),
                    SizedBox(width: 20),
                    Text(
                      'Agregar producto',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Nombre:',
                      style: TextStyle(color: Colors.black),
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
                          child: Text(value,
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Precio'),
                      controller: _precioController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  if (double.tryParse(_precioController.text) != null &&
                      double.parse(_precioController.text) <= 0)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        'El precio debe ser mayor a 0',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'Cantidad'),
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  if (int.tryParse(_cantidadController.text) != null &&
                      int.parse(_cantidadController.text) < 1)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Text(
                        'La cantidad debe ser mayor o igual a 1',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
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
              ),
              const SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
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
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedImage != null &&
                        double.tryParse(_precioController.text) != null &&
                        double.parse(_precioController.text) > 0 &&
                        int.tryParse(_cantidadController.text) != null &&
                        int.parse(_cantidadController.text) >= 1) {
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

  Future<void> _agregarProducto() async {
    final nombre = _selectedProducto;
    final precio = double.parse(_precioController.text);
    final cantidad = int.parse(_cantidadController.text);

    final productoService = ProductoService();
    final Future<String?> imageUrlFuture =
        productoService.subirImagen(_selectedImage);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16.0),
              Text("Subiendo imagen..."),
            ],
          ),
        );
      },
    );

    imageUrlFuture.then((imageUrl) async {
      Navigator.of(context).pop(); // Cerrar el diálogo de carga

      final nuevoProducto = Producto(
        nombre: nombre,
        precio: precio,
        cantidad: cantidad,
        disponible: _disponible,
        imagen: _selectedImage,
        calidad: _selectedCalidad,
      );

      await productoService.agregarProducto(nuevoProducto, imageUrl!);

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
                  Navigator.pushNamed(context, '/disponibilidadproducto');
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    });
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
