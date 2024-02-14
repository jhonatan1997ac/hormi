import 'dart:io';

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
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
      title: 'Disponibilidad de producto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DisponibilidadProducto(),
    );
  }
}

class DisponibilidadProducto extends StatefulWidget {
  const DisponibilidadProducto({Key? key}) : super(key: key);

  @override
  _DisponibilidadProductoState createState() => _DisponibilidadProductoState();
}

class _DisponibilidadProductoState extends State<DisponibilidadProducto> {
  late CollectionReference productosCollection;
  File? _imagen;

  @override
  void initState() {
    super.initState();
    productosCollection =
        FirebaseFirestore.instance.collection('disponibilidadproducto');
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
        calidad: producto.calidad,
      );

      bool confirmacion = await _mostrarConfirmacion(context, productoEditado);

      if (confirmacion) {
        await productosCollection.doc(producto.id).update({
          'nombre': productoEditado.nombre,
          'precio': productoEditado.precio,
          'cantidad': productoEditado.cantidad,
          'disponible': productoEditado.disponible,
          'imagen': productoEditado.imagen,
          'calidad': productoEditado.calidad,
        });

        print('Producto actualizado: $productoEditado');
      }
    } catch (e) {
      print('Error al editar el producto: $e');
    }
  }

  Future<void> eliminarProducto(Producto producto) async {
    try {
      bool confirmacion = await _mostrarConfirmacionEliminar(context);
      if (confirmacion) {
        await productosCollection.doc(producto.id).delete();

        if (producto.imagen != null) {
          await FirebaseStorage.instance.refFromURL(producto.imagen!).delete();
        }

        print('Producto eliminado: $producto');
      }
    } catch (e) {
      print('Error al eliminar el producto: $e');
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
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Edición'),
              content:
                  const Text('¿Está seguro de que desea editar este producto?'),
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
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _mostrarConfirmacionEliminar(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Eliminación'),
              content: const Text(
                  '¿Está seguro de que desea eliminar este producto?'),
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
          'Disponibilidad de producto',
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
                            color: Colors
                                .white, // Establecer el color de fondo en blanco
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0,
                                    3), // Cambiar la posición de la sombra si lo deseas
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(producto.nombre),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Precio: \$${producto.precio.toStringAsFixed(2)}'),
                                Text('Cantidad: ${producto.cantidad}'),
                                Text(
                                    'Disponibilidad: ${producto.disponible ? 'Disponible' : 'No disponible'}'),
                                Text('Calidad: ${producto.calidad}'),
                              ],
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditarProductoScreen(
                                          producto: producto,
                                        ),
                                      ),
                                    ).then((productoActualizado) async {
                                      if (productoActualizado != null) {
                                        await editarProducto(
                                            productoActualizado);
                                        print(
                                            'Producto actualizado: $productoActualizado');
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    eliminarProducto(producto);
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
  final bool disponible;
  String? imagen;
  String calidad;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.disponible,
    this.imagen,
    required this.calidad,
  });

  Producto.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        nombre = snapshot['nombre'] ?? '',
        precio = (snapshot['precio'] as num?)?.toDouble() ?? 0.0,
        cantidad = (snapshot['cantidad'] as num?)?.toInt() ?? 0,
        disponible = snapshot['disponible'] ?? false,
        imagen = snapshot['imagen'] as String?,
        calidad = snapshot['calidad'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'disponible': disponible,
      'imagen': imagen,
      'calidad': calidad,
    };
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
  bool _disponible = true;
  String _selectedProducto = 'Adoquin jaboncillo peatonal sin color';
  String _selectedCalidad =
      'Calidad adoquin resistencia 300'; // Selecciona una calidad por defecto
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
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto.nombre);
    precioController =
        TextEditingController(text: widget.producto.precio.toString());
    cantidadController =
        TextEditingController(text: widget.producto.cantidad.toString());

    _selectedProducto = widget.producto.nombre;
    _selectedCalidad = widget.producto.calidad; // Set calidad inicial
  }

  @override
  Widget build(BuildContext context) {
    // Verificar si el valor seleccionado no es único y ajustarlo si es necesario
    if (!_productos.contains(_selectedProducto)) {
      _selectedProducto =
          _productos[0]; // Asignar el primer producto como valor seleccionado
    }

    if (!_calidad.contains(_selectedCalidad)) {
      _selectedCalidad =
          _calidad[0]; // Asignar la primera calidad como valor seleccionado
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              items: _productos.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: precioController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                if (precioController.text.isNotEmpty &&
                    cantidadController.text.isNotEmpty) {
                  final productoActualizado = Producto(
                    id: widget.producto.id,
                    nombre: _selectedProducto,
                    precio: double.tryParse(precioController.text) ?? 0.0,
                    cantidad: int.tryParse(cantidadController.text) ?? 0,
                    disponible: _disponible,
                    imagen: widget.producto.imagen,
                    calidad: _selectedCalidad,
                  );

                  Navigator.pop(context, productoActualizado);
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
