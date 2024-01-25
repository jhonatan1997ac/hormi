import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
        FirebaseFirestore.instance.collection('disponibilidadproducto');
  }

  Future<void> agregarProducto(Producto nuevoProducto) async {
    try {
      if (_imagen != null) {
        String imagen = await subirImagen(_imagen!);
        await productosCollection.add({
          'nombre': nuevoProducto.nombre,
          'precio': nuevoProducto.precio,
          'cantidad': nuevoProducto.cantidad,
          'disponible': nuevoProducto.disponible,
          'imagen': imagen,
        });
        setState(() {
          _imagen = null;
        });
      } else {
        await productosCollection.add({
          'nombre': nuevoProducto.nombre,
          'precio': nuevoProducto.precio,
          'cantidad': nuevoProducto.cantidad,
          'disponible': nuevoProducto.disponible,
        });
      }
    } catch (e) {
      print('Error al agregar el producto: $e');
    }
  }

  Future<void> editarProducto(Producto producto) async {
    try {
      Producto productoEditado = Producto(
        id: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
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

        print('Producto actualizado: $productoEditado');
      }
    } catch (e) {
      print('Error al editar el producto: $e');
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

  Future<bool> _mostrarConfirmacion(
      BuildContext context, Producto producto) async {
    // Aquí puedes implementar la lógica para mostrar la confirmación.
    // Por ejemplo, puedes usar showDialog().
    return true;
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
                          onPressed: () async {
                            bool confirmacion =
                                await _mostrarConfirmacion(context, producto);
                            if (confirmacion) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditarProductoScreen(producto: producto),
                                ),
                              ).then((productoActualizado) async {
                                if (productoActualizado != null) {
                                  await editarProducto(productoActualizado);
                                  print(
                                      'Producto actualizado: $productoActualizado');
                                }
                              });
                            }
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
  final String id;
  final String nombre;
  final double precio;
  final int cantidad;
  final bool disponible;
  String? imagen;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.disponible,
    this.imagen,
  });

  Producto.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        nombre = snapshot['nombre'] ?? '',
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

class AgregarProductoScreen extends StatefulWidget {
  @override
  _AgregarProductoScreenState createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController disponibleController = TextEditingController();

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
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Precio del Producto'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Cantidad'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: disponibleController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Disponible (true/false)'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isNotEmpty &&
                    precioController.text.isNotEmpty &&
                    cantidadController.text.isNotEmpty &&
                    disponibleController.text.isNotEmpty) {
                  final nombreCapitalizado =
                      _capitalizeFirstLetter(nombreController.text);

                  final nuevoProducto = Producto(
                    id: '',
                    nombre: nombreCapitalizado,
                    precio: double.tryParse(precioController.text) ?? 0.0,
                    cantidad: int.tryParse(cantidadController.text) ?? 0,
                    disponible:
                        disponibleController.text.toLowerCase() == 'true',
                    imagen: null,
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

class EditarProductoScreen extends StatefulWidget {
  final Producto producto;

  EditarProductoScreen({required this.producto});

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
              decoration:
                  const InputDecoration(labelText: 'Nombre del Producto'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: precioController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Precio del Producto'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: disponibleController,
              keyboardType: TextInputType.text,
              decoration:
                  const InputDecoration(labelText: 'Disponible (true/false)'),
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

                    final productoActualizado = Producto(
                      id: widget.producto.id,
                      nombre: nombreCapitalizado,
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
  // Aquí puedes implementar la lógica para mostrar la confirmación.
  // Por ejemplo, puedes usar showDialog().
  return true;
}
