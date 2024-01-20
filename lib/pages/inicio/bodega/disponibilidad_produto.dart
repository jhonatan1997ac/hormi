import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datos ingresados',
      home: DisponibilidadProducto(),
    );
  }
}

class DisponibilidadProducto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Datos ingresados'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('disponibilidadproducto')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          var productos = snapshot.data!.docs;
          if (productos.isEmpty) {
            return const Center(
              child: Text('No existe ningún dato.'),
            );
          }

          List<Widget> productosWidget = [];
          for (var producto in productos) {
            var productoData = producto.data() as Map<String, dynamic>;
            productosWidget.add(
              ListTile(
                title: Text(productoData['nombre']),
                subtitle: Text(
                    'Precio: ${productoData['precio']}, Cantidad: ${productoData['cantidad']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Disponible: ${productoData['disponible'] == 1 ? 'Sí' : 'No'}',
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarProducto(
                              productoId: producto.id,
                              nombre: productoData['nombre'],
                              precio: productoData['precio'],
                              cantidad: productoData['cantidad'],
                              disponible: productoData['disponible'] == 1,
                              imagenURL: productoData['imagen'],
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _eliminarProducto(producto.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            children: productosWidget,
          );
        },
      ),
    );
  }

  void _eliminarProducto(String productoId) async {
    await FirebaseFirestore.instance
        .collection('disponibilidadproducto')
        .doc(productoId)
        .delete();
  }
}

class EditarProducto extends StatefulWidget {
  final String productoId;
  final String nombre;
  final double precio;
  final int cantidad;
  final bool disponible;
  final String? imagenURL;

  EditarProducto({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.disponible,
    this.imagenURL,
  });

  @override
  _EditarProductoState createState() => _EditarProductoState();
}

class _EditarProductoState extends State<EditarProducto> {
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _cantidadController;
  late bool _disponible;
  late File _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.nombre);
    _precioController = TextEditingController(text: widget.precio.toString());
    _cantidadController =
        TextEditingController(text: widget.cantidad.toString());
    _disponible = widget.disponible;
    _selectedImage = File(""); // Initialize with an empty file

    // Set the initial image if available
    if (widget.imagenURL != null && widget.imagenURL!.isNotEmpty) {
      _selectedImage = File(widget.imagenURL!);
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _precioController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _cantidadController,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
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
            ElevatedButton(
              onPressed: _seleccionarImagen,
              child: const Text('Seleccionar Imagen'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _actualizarProducto();
                Navigator.pop(context);
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  Future<void> _actualizarProducto() async {
    String imagenURL = widget.imagenURL ?? "";

    // Actualizar la imagen si se seleccionó una nueva
    if (_selectedImage.path.isNotEmpty) {
      imagenURL = await _subirImagen(_selectedImage);
    }

    await FirebaseFirestore.instance
        .collection('disponibilidadproducto')
        .doc(widget.productoId)
        .update({
      'nombre': _nombreController.text,
      'precio': double.parse(_precioController.text),
      'cantidad': int.parse(_cantidadController.text),
      'disponible': _disponible ? 1 : 0,
      'imagen': imagenURL,
    });
  }

  Future<String> _subirImagen(File imageFile) async {
    try {
      final storageReference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('productos/${DateTime.now().toIso8601String()}');
      await storageReference.putFile(imageFile);
      return await storageReference.getDownloadURL();
    } catch (e) {
      print('Error al subir la imagen: $e');
      return "";
    }
  }
}
