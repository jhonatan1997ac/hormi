import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    productosCollection = FirebaseFirestore.instance.collection('productos');
  }

  Future<void> agregarProducto(Producto nuevoProducto) async {
    try {
      if (_imagen != null) {
        String imagen = await subirImagen(_imagen!);
        await productosCollection.add({
          'nombre': nuevoProducto.nombre,
          'precio': nuevoProducto.precio,
          'imagen': imagen,
        });
        setState(() {
          _imagen = null; // Limpiar la imagen después de agregar el producto
        });
      } else {
        await productosCollection.add({
          'nombre': nuevoProducto.nombre,
          'precio': nuevoProducto.precio,
        });
      }
    } catch (e) {
      print('Error al agregar el producto: $e');
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
      print('Error al subir la imagen: $e');
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
      print('Error al cargar la imagen: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final nuevoProducto = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarProductoScreen(),
                  ),
                );

                if (nuevoProducto != null) {
                  final imagenFile = await _cargarImagen();
                  if (imagenFile != null) {
                    await agregarProducto(nuevoProducto);
                  }
                }
              },
              child: Text('Agregar Producto'),
            ),
            SizedBox(height: 16.0),
            _imagen != null
                ? Image.file(
                    _imagen!,
                    width: 150.0,
                    height: 150.0,
                    fit: BoxFit.cover,
                  )
                : SizedBox.shrink(),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: productosCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final producto =
                          Producto.fromSnapshot(snapshot.data!.docs[index]);
                      return ListTile(
                        title: Text(producto.nombre),
                        subtitle: Text(
                            'Precio: \$${producto.precio.toStringAsFixed(2)}'),
                        leading: producto.imagen != null
                            ? Image.network(
                                producto.imagen!,
                                width: 50.0,
                                height: 50.0,
                              )
                            : SizedBox.shrink(),
                        trailing: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Implementa la lógica para editar el producto
                            // Puedes usar Navigator.push para navegar a la pantalla de edición
                          },
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
    );
  }
}

class Producto {
  final String nombre;
  final double precio;
  String? imagen;

  Producto({required this.nombre, required this.precio, this.imagen});

  Producto.fromSnapshot(DocumentSnapshot snapshot)
      : nombre = snapshot['nombre'] ?? '',
        precio = (snapshot['precio'] as num?)?.toDouble() ?? 0.0,
        imagen = snapshot['imagen'] as String?;

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'imagen': imagen,
    };
  }
}

class AgregarProductoScreen extends StatefulWidget {
  @override
  _AgregarProductoScreenState createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre del Producto'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Precio del Producto'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isNotEmpty &&
                    precioController.text.isNotEmpty) {
                  final nombreCapitalizado =
                      _capitalizeFirstLetter(nombreController.text);

                  final nuevoProducto = Producto(
                    nombre: nombreCapitalizado,
                    precio: double.tryParse(precioController.text) ?? 0.0,
                    imagen: null, // No es necesario asignar imagen aquí
                  );

                  Navigator.pop(context, nuevoProducto);
                }
              },
              child: const Text('Agregar Producto'),
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
