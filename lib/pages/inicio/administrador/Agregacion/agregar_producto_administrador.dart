// ignore_for_file: unused_field, use_build_context_synchronously, use_key_in_widget_constructors, prefer_const_declarations, library_private_types_in_public_api

import 'dart:io';

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Map<String, int> cantidadesPredeterminadas = {
  'Adoquin clasico vehicular sin color': 3034,
  'Adoquin clasico vehicular con color': 3034,
  'Adoquin jaboncillo vehicular sin color': 7585,
  'Adoquin jaboncillo vehicular con color': 7585,
  'Adoquin paleta vehicular sin color': 5612,
  'Adoquin paleta vehicular con color': 5612,
  'Bloque de 10cm alivianado': 1050,
  'Bloque de 10cm estructural': 1050,
  'Bloque de 15cm alivianado': 800,
  'Bloque de 15cm estructural': 800,
  'Postes de alambrado 1.60m': 504,
  'Postes de alambrado 2m': 396,
  'Bloque de anclaje': 468,
  'Tapas para canaleta': 234,
};

class ProductoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> agregarProducto(
      Producto nuevoProducto, String imageUrl, int cantidad) async {
    try {
      await _firestore.collection('productoterminado').add({
        'nombre': nuevoProducto.nombre,
        'precio': nuevoProducto.precio,
        'disponible': nuevoProducto.disponible,
        'imagen': imageUrl,
        'calidad': nuevoProducto.calidad,
        'cantidad': cantidad,
      });
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
        return await storageReference.getDownloadURL();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir la imagen: $e');
      }
      return null;
    }
  }

  Future<int?> obtenerCantidadProductoDesdeFirestore(String producto) async {
    try {
      final docSnapshot =
          await _firestore.collection('procesoproducto').doc(producto).get();
      final data = docSnapshot.data();
      if (data != null && data.containsKey('cantidad')) {
        return data['cantidad'] as int?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error al obtener la cantidad del producto desde Firestore: $e');
      }
      return null;
    }
  }
}

class Producto {
  String nombre;
  double precio;
  bool disponible;
  File? imagen;
  String calidad;

  Producto({
    required this.nombre,
    required this.precio,
    required this.disponible,
    this.imagen,
    required this.calidad,
  });

  bool get estaDisponible => disponible;

  static fromSnapshot(QueryDocumentSnapshot<Object?> doc) {}
}

class ProductosAdministrador extends StatefulWidget {
  final String selectedProduct;
  final String cantidadProducto;

  const ProductosAdministrador({
    Key? key,
    required this.selectedProduct,
    required this.cantidadProducto,
  }) : super(key: key);

  @override
  _ProductosAdministradorState createState() => _ProductosAdministradorState();
}

class _ProductosAdministradorState extends State<ProductosAdministrador> {
  bool _disponible = true;
  String _selectedCalidad = 'Calidad adoquin resistencia 300';
  File? _selectedImage;

  final List<String> _calidadOptions = [
    'Calidad adoquin resistencia 300',
    'Calidad adoquin resistencia 350',
    'Calidad adoquin resistencia 400',
    'Calidad bloques 2MPA',
    'Calidad bloques 4MPA',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
              Color.fromARGB(255, 55, 111, 139),
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
                    Text(
                      widget.selectedProduct,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Text(
                            'Calidad:',
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(width: 16.0),
                          DropdownButton<String>(
                            value: _selectedCalidad,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCalidad = newValue!;
                              });
                            },
                            items: _calidadOptions
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
                    Row(
                      children: [
                        const Text(
                          'Disponible:',
                          style: TextStyle(color: Colors.black),
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
                  if (_selectedImage != null) {
                    final cantidadPredeterminada =
                        cantidadesPredeterminadas[widget.selectedProduct];
                    await _agregarProducto(cantidadPredeterminada ?? 0);
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

  Future<void> _agregarProducto(int cantidadPredeterminada) async {
    final nombre = widget.selectedProduct;
    final calidad = _selectedCalidad;
    double precio = 0.0;
    switch (nombre) {
      case 'Adoquin clasico vehicular sin color':
        precio = 0.30;
        break;
      case 'Adoquin clasico vehicular con color':
        precio = 0.50;
        break;
      case 'Adoquin jaboncillo vehicular sin color':
        precio = 0.16;
        break;
      case 'Adoquin jaboncillo vehicular con color':
        precio = 0.20;
        break;
      case 'Adoquin paleta vehicular sin color':
        precio = 0.21;
        break;
      case 'Adoquin paleta vehicular con color':
        precio = 0.27;
        break;
      case 'Bloque de 10cm estructural':
        precio = 0.35;
        break;
      case 'Bloque de 15cm estructural':
        precio = 0.40;
        break;
      case 'Postes de alambrado 1.60m':
        precio = 6;
        break;
      case 'Postes de alambrado 2m':
        precio = 7;
        break;
      case 'Bloque de anclaje':
        precio = 3.50;
        break;
      case 'Tapas para canaleta':
        precio = 56;
        break;
      default:
        precio = 0.0;
    }

    final productoService = ProductoService();
    final imageUrl = await productoService.subirImagen(_selectedImage);

    if (imageUrl != null) {
      final cantidadDesdeFirestore = await productoService
          .obtenerCantidadProductoDesdeFirestore(widget.selectedProduct);
      final cantidadTotal =
          cantidadPredeterminada + (cantidadDesdeFirestore ?? 0);

      final nuevoProducto = Producto(
        nombre: nombre,
        precio: precio,
        disponible: _disponible,
        imagen: _selectedImage,
        calidad: calidad,
      );

      await productoService.agregarProducto(
          nuevoProducto, imageUrl, cantidadTotal);

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
                      context, '/GestiornarProductoAdministrador');
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
    return MaterialApp(
      title: 'Mi Aplicación',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const ProcesoProductosScreen(),
        '/disponibilidadproductoadministrador': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is String) {
            return ProductosAdministrador(
              selectedProduct: arguments,
              cantidadProducto: '',
            );
          } else {
            return const Scaffold(
              body: Center(
                child: Text('No se proporcionaron argumentos'),
              ),
            );
          }
        },
      },
    );
  }
}

class ProcesoProductosScreen extends StatelessWidget {
  const ProcesoProductosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final selectedProduct = 'nombre';
            Navigator.pushNamed(
              context,
              '/disponibilidadproductoadministrador',
              arguments: selectedProduct,
            );
          },
          child: const Text('Seleccionar Producto'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
