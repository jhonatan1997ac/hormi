// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously

import 'package:apphormi/pages/inicio/vendedores/carrito_compra.dart';
import 'package:apphormi/pages/inicio/vendedores/pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String? imagen;
  int cantidad;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.imagen,
    required this.cantidad,
  });
}

class Ventas extends StatefulWidget {
  const Ventas({Key? key}) : super(key: key);

  @override
  _VentasState createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  List<Producto> productosDisponibles = [];
  List<Producto> carrito = [];
  String? errorMessage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    cargarProductosDesdeFirestore();
  }

  Future<void> cargarProductosDesdeFirestore() async {
    CollectionReference productoterminadoCollection =
        FirebaseFirestore.instance.collection('productoterminado');

    QuerySnapshot querySnapshot = await productoterminadoCollection.get();

    List<Producto> productos = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Producto(
        id: doc.id,
        nombre: data['nombre'] ?? '',
        precio: (data['precio'] ?? 0.0).toDouble(),
        imagen: data['imagen'],
        cantidad: data['cantidad'] ?? 0,
      );
    }).toList();

    setState(() {
      productosDisponibles = productos;
    });
  }

  Future<void> mostrarDialogCantidad(Producto producto) async {
    int selectedQuantity = 1;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cantidad de Productos'),
          content: Column(
            children: [
              Text(
                  'Ingrese la cantidad de ${producto.nombre} que desea comprar:'),
              TextField(
                controller:
                    TextEditingController(text: selectedQuantity.toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null && parsedValue > 0) {
                    selectedQuantity = parsedValue;
                  } else {
                    setState(() {
                      errorMessage = 'La cantidad no puede ser negativa';
                    });
                  }
                },
              ),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (await verificarDisponibilidad(producto, selectedQuantity)) {
                  agregarAlCarrito(producto, selectedQuantity);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void mostrarMensajeEmergente(String mensaje, {Color color = Colors.white}) {
    OverlayEntry overlayEntry;

    double overlayTop = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).size.height * 0.12;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayTop,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 1), () {
      overlayEntry.remove();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => IniciarPedido()),
      );
    });
  }

  Future<bool> verificarDisponibilidad(
      Producto producto, int selectedQuantity) async {
    if (producto.cantidad >= selectedQuantity &&
        (producto.cantidad - selectedQuantity) >= 2300) {
      setState(() {
        errorMessage = null;
      });
      return true;
    } else {
      mostrarMensajeEmergente(
          'No hay suficiente cantidad disponible o el stock mínimo no se alcanza',
          color: Colors.red);
      return false;
    }
  }

  Future<void> restarCantidadEnFirestore(
      Producto producto, int quantityToSubtract) async {
    try {
      DocumentReference productoRef = FirebaseFirestore.instance
          .collection('productoterminado')
          .doc(producto.id);

      DocumentSnapshot snapshot = await productoRef.get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El producto no existe en la base de datos.'),
          ),
        );
        return;
      }

      int cantidadActual = snapshot['cantidad'] ?? 0;
      if (cantidadActual >= quantityToSubtract) {
        await productoRef
            .update({'cantidad': FieldValue.increment(-quantityToSubtract)});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay suficiente cantidad disponible'),
          ),
        );
      }

      await cargarProductosDesdeFirestore();
    } catch (error) {
      if (kDebugMode) {
        print("Error al restar la cantidad en Firestore: $error");
      }
    }
  }

  Future<void> agregarAlCarrito(Producto producto, int quantity) async {
    try {
      await restarCantidadEnFirestore(producto, quantity);

      setState(() {
        carrito.add(
          Producto(
            id: producto.id,
            nombre: producto.nombre,
            precio: producto.precio,
            imagen: producto.imagen,
            cantidad: quantity,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito'),
        ),
      );

      // Navegar a la vista del carrito
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CarritoDeCompras(carrito: carrito),
        ),
      );
    } catch (error) {
      if (kDebugMode) {
        print("Error al agregar al carrito: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Ventas",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 5,
        actions: [
          IconButton(
            onPressed: () {
              if (carrito.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarritoDeCompras(carrito: []),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El carrito está vacío'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.shopping_cart),
          ),
        ],
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 85, 142, 165),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Productos Disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 250, 250, 250),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: productosDisponibles.length,
                  itemBuilder: (context, index) {
                    final producto = productosDisponibles[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Cantidad: ${producto.cantidad} unidades',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Precio:  \$${producto.precio.toStringAsFixed(2)}  c/u',
                              style: const TextStyle(fontSize: 16),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                mostrarDialogCantidad(producto);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 97, 228, 125),
                              ),
                              child: const Text('Agregar al Carrito'),
                            ),
                          ],
                        ),
                        leading: SizedBox(
                          width: 50.0,
                          child: producto.imagen != null
                              ? Image.network(producto.imagen!)
                              : const Placeholder(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 85, 142, 165),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 161, 157, 157)
                          .withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (carrito.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CarritoDeCompras(carrito: []),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El carrito está vacío'),
                        ),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_cart), // Icono del carrito
                            SizedBox(
                                width: 10), // Espacio entre el icono y el texto
                            Text(
                              'Ver el carrito',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey, // Color gris
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Ventas(),
  ));
}
