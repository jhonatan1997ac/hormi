// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, unused_element

import 'dart:io';

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Productos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GestionProductos(),
    );
  }
}

class GestionProductos extends StatefulWidget {
  @override
  _GestionProductosState createState() => _GestionProductosState();
}

class _GestionProductosState extends State<GestionProductos> {
  late CollectionReference productosCollection;
  File? _imagen;

  @override
  void initState() {
    super.initState();
    productosCollection =
        FirebaseFirestore.instance.collection('productoterminado');
  }

  Future<void> editarProducto(Producto producto) async {
    try {
      Producto productoEditado = Producto(
        id: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        calidad: producto.calidad,
        cantidad: producto.cantidad,
        disponible: producto.disponible,
        imagen: producto.imagen,
      );
      bool confirmacion = await _mostrarConfirmacion(context, productoEditado);
      if (confirmacion) {
        await productosCollection.doc(producto.id).update({
          'nombre': productoEditado.nombre,
          'precio': productoEditado.precio,
          'cantidad': productoEditado.cantidad,
          'disponible': productoEditado.disponible,
          'imagen': productoEditado.imagen,
        });

        if (kDebugMode) {
          print('Producto actualizado: $productoEditado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al editar el producto: $e');
      }
    }
  }

  Future<void> eliminarProducto(Producto producto) async {
    try {
      Object confirmacion =
          await _mostrarConfirmacionEliminar(context, producto);
      if (confirmacion) {
        await productosCollection.doc(producto.id).delete();
        if (kDebugMode) {
          print('Producto eliminado: ${producto.nombre}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar el producto: $e');
      }
    }
  }

  Future<String> subirImagen(File imagen) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('imagenes_productos/${DateTime.now().millisecondsSinceEpoch}');

      UploadTask uploadTask = storageReference.putFile(imagen);
      await uploadTask.whenComplete(() => null);

      String imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Error al subir la imagen: $e');
      }
      throw Exception('Error al subir la imagen');
    }
  }

  Future<File?> _cargarImagen() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imagen = File(pickedFile.path);
        });
        return _imagen;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al cargar la imagen: $e');
      }
    }
    return null;
  }

  Future<bool> _mostrarConfirmacion(
      BuildContext context, Producto producto) async {
    return true;
  }

  Future<Object> _mostrarConfirmacionEliminar(
      BuildContext context, Producto producto) async {
    return showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar eliminación'),
              content: Text(
                  '¿Estás seguro de que deseas eliminar ${producto.nombre}?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Productos',
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
              const SizedBox(height: 16.0),
              _imagen != null
                  ? Image.file(
                      _imagen!,
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 16.0),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: productosCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final producto =
                            Producto.fromSnapshot(snapshot.data!.docs[index]);
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          child: ListTile(
                            title: Text(
                              producto.calidad,
                              style: const TextStyle(color: Colors.black),
                            ),
                            subtitle: Text(
                              'Cantidad: ${producto.cantidad}',
                              style: const TextStyle(color: Colors.black),
                            ),
                            leading: producto.imagen != null
                                ? Image.network(
                                    producto.imagen!,
                                    width: 50.0,
                                    height: 50.0,
                                  )
                                : const SizedBox.shrink(),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    bool confirmacion =
                                        await _mostrarConfirmacion(
                                            context, producto);
                                    if (confirmacion) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditarProductoScreen(
                                                  producto: producto),
                                        ),
                                      ).then((productoActualizado) async {
                                        if (productoActualizado != null) {
                                          await editarProducto(
                                              productoActualizado);
                                          if (kDebugMode) {
                                            print(
                                                'Producto actualizado: $productoActualizado');
                                          }
                                        }
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    Object confirmacion =
                                        (await _mostrarConfirmacionEliminar(
                                                context, producto)) ??
                                            false;
                                    if (confirmacion) {
                                      eliminarProducto(producto);
                                    }
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final int cantidad;
  final String calidad;
  final bool disponible;
  String? imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.calidad,
    required this.precio,
    required this.cantidad,
    required this.disponible,
    this.imagen,
  });

  Producto.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        nombre = snapshot['nombre'] ?? '',
        calidad = snapshot['calidad'] ?? '',
        precio = (snapshot['precio'] as num?)?.toDouble() ?? 0.0,
        cantidad = (snapshot['cantidad'] as num?)?.toInt() ?? 0,
        disponible = snapshot['disponible'] ?? false,
        imagen = snapshot['imagen'] as String?;

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'disponible': disponible,
      'imagen': imagen,
    };
  }
}

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  const EditarProductoScreen({required this.producto});

  @override
  _EditarProductoScreenState createState() => _EditarProductoScreenState();
}

class _EditarProductoScreenState extends State<EditarProductoScreen> {
  late TextEditingController nombreController;
  late TextEditingController precioController;
  late TextEditingController cantidadController;
  late TextEditingController disponibleController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto.nombre);
    precioController =
        TextEditingController(text: widget.producto.precio.toString());
    cantidadController =
        TextEditingController(text: widget.producto.cantidad.toString());
    disponibleController =
        TextEditingController(text: widget.producto.disponible.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Producto',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: precioController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio del Producto',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: disponibleController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Disponible (true/false)',
                fillColor: Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                bool confirmacion =
                    await _mostrarConfirmacion(context, widget.producto);

                if (confirmacion) {
                  if (nombreController.text.isNotEmpty &&
                      precioController.text.isNotEmpty &&
                      cantidadController.text.isNotEmpty &&
                      disponibleController.text.isNotEmpty) {
                    final nombreCapitalizado =
                        _capitalizeFirstLetter(nombreController.text);
                    final calidad =
                        _capitalizeFirstLetter(nombreController.text);

                    final productoActualizado = Producto(
                      id: widget.producto.id,
                      nombre: nombreCapitalizado,
                      calidad: calidad,
                      precio: double.tryParse(precioController.text) ?? 0.0,
                      cantidad: int.tryParse(cantidadController.text) ?? 0,
                      disponible:
                          disponibleController.text.toLowerCase() == 'true',
                      imagen: widget.producto.imagen,
                    );

                    Navigator.pop(context, productoActualizado);
                  }
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

Future<bool> _mostrarConfirmacion(
    BuildContext context, Producto producto) async {
  return true;
}
