// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String nombre;
  final double precio;
  final String? imagen;

  Producto({required this.nombre, required this.precio, this.imagen});
}

class HistorialVenta {
  final List<Producto> productos;
  final double subtotal;
  final double iva;
  final double total;
  final String metodoPago;
  final DateTime fecha;

  HistorialVenta({
    required this.productos,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.metodoPago,
    required this.fecha,
  });
}

class CalculosVenta {
  static void mostrarTotalVenta(
      BuildContext context, List<Producto> carrito, String metodoPago) {
    // Calcular el total con el IVA al 0.12%
    double subtotal =
        carrito.fold(0.0, (sum, producto) => sum + producto.precio);
    double iva = subtotal * 0.15;
    double total = subtotal + iva;

    // Crear instancia de HistorialVenta
    HistorialVenta historialVenta = HistorialVenta(
      productos: carrito,
      subtotal: subtotal,
      iva: iva,
      total: total,
      metodoPago: metodoPago,
      fecha: DateTime.now(),
    );

    // Guardar la venta en el historial
    guardarVentaEnHistorial(historialVenta);

    // Mostrar la factura
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Factura de Venta'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detalles de la Venta:'),
              const SizedBox(height: 8),
              Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
              Text('IVA (0.15%): \$${iva.toStringAsFixed(2)}'),
              Text('Total: \$${total.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              Text('Método de Pago: $metodoPago'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  static void guardarVentaEnHistorial(HistorialVenta venta) {
    FirebaseFirestore.instance
        .collection('historial_ventas')
        .add({
          'disponibilidadproducto': venta.productos
              .map((producto) => {
                    'nombre': producto.nombre,
                    'precio': producto.precio,
                  })
              .toList(),
          'subtotal': venta.subtotal,
          'iva': venta.iva,
          'total': venta.total,
          'metodoPago': venta.metodoPago,
          'fecha': venta.fecha,
        })
        .then((value) => print("Venta guardada en historial"))
        .catchError((error) => print("Error al guardar la venta: $error"));
  }
}

class Ventas extends StatefulWidget {
  const Ventas({super.key});

  @override
  _VentasState createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  List<Producto> productosDisponibles = [];
  List<Producto> carrito = [];
  String metodoPago = 'Efectivo'; // Por defecto, se asume efectivo

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
        nombre: data['nombre'] ?? '',
        precio: (data['precio'] ?? 0.0).toDouble(),
      );
    }).toList();

    setState(() {
      productosDisponibles = productos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas '),
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
                    title: Text(producto.nombre),
                    subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
                    leading: SizedBox(
                      width: 50.0,
                      child: producto.imagen != null
                          ? Image.network(producto.imagen!)
                          : const Placeholder(),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        agregarAlCarrito(producto);
                      },
                      child: const Text('Agregar al Carrito'),
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
                    title: Text(producto.nombre),
                    subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: metodoPago,
                  onChanged: (String? newValue) {
                    setState(() {
                      metodoPago = newValue!;
                    });
                  },
                  items: ['Efectivo', 'Tarjeta']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                ElevatedButton(
                  onPressed: () {
                    finalizarVenta();
                  },
                  child: const Text('Finalizar Venta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void agregarAlCarrito(Producto producto) {
    setState(() {
      carrito.add(producto);
    });
  }

  void finalizarVenta() {
    CalculosVenta.mostrarTotalVenta(context, carrito, metodoPago);

    // Limpia el carrito después de finalizar la venta
    setState(() {
      carrito.clear();
    });
  }
}

void main() {
  runApp(MaterialApp(
    home: Ventas(),
  ));
}
