import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String
      id; // Agregamos un campo id para identificar de manera única el producto
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

  @override
  void initState() {
    super.initState();
    cargarProductosDesdeFirestore();
  }

  Future<void> cargarProductosDesdeFirestore() async {
    CollectionReference disponibilidadproductoCollection =
        FirebaseFirestore.instance.collection('disponibilidadproducto');

    QuerySnapshot querySnapshot = await disponibilidadproductoCollection.get();

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('La cantidad no puede ser negativa'),
                      ),
                    );
                  }
                },
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

  Future<bool> verificarDisponibilidad(
      Producto producto, int selectedQuantity) async {
    // Verificar si hay suficiente cantidad disponible en la base de datos
    if (producto.cantidad >= selectedQuantity) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay suficiente cantidad disponible'),
        ),
      );
      return false;
    }
  }

  Future<void> restarCantidadEnFirestore(
      Producto producto, int quantityToSubtract) async {
    try {
      DocumentReference productoRef = FirebaseFirestore.instance
          .collection('disponibilidadproducto')
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
        // Utilizar update para realizar una actualización atómica
        await productoRef
            .update({'cantidad': FieldValue.increment(-quantityToSubtract)});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay suficiente cantidad disponible'),
          ),
        );
      }

      // Cargar los productos actualizados desde Firestore
      await cargarProductosDesdeFirestore();
    } catch (error) {
      print("Error al restar la cantidad en Firestore: $error");
      // Puedes manejar el error según tus necesidades
    }
  }

  Future<void> agregarAlCarrito(Producto producto, int quantity) async {
    try {
      // Restar la cantidad en Firestore
      await restarCantidadEnFirestore(producto, quantity);

      // Actualizar el carrito en el estado
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

      // Mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito'),
        ),
      );
    } catch (error) {
      print("Error al agregar al carrito: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productos Disponibles'),
            Expanded(
              child: ListView.builder(
                itemCount: productosDisponibles.length,
                itemBuilder: (context, index) {
                  final producto = productosDisponibles[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${producto.nombre} '),
                        Text('Cantidad: ${producto.cantidad}'),
                        Text('\$${producto.precio.toStringAsFixed(2)}'),
                        ElevatedButton(
                          onPressed: () {
                            mostrarDialogCantidad(producto);
                          },
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Carrito de Compras'),
            Expanded(
              child: ListView.builder(
                itemCount: carrito.length,
                itemBuilder: (context, index) {
                  final producto = carrito[index];
                  return ListTile(
                    title: Text('${producto.nombre} '),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${producto.precio.toStringAsFixed(2)}'),
                        Text('Cantidad: ${producto.cantidad}'),
                      ],
                    ),
                    leading: SizedBox(
                      width: 50.0,
                      child: producto.imagen != null
                          ? Image.network(producto.imagen!)
                          : const Placeholder(),
                    ),
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

void main() {
  runApp(const MaterialApp(
    home: Ventas(),
  ));
}
