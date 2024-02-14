import 'package:apphormi/pages/inicio/vendedores/vendedor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String nombre;
  final double precio;

  Producto({
    required this.nombre,
    required this.precio,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'precio': precio,
    };
  }
}

class Venta {
  final List<Producto> productos;
  final String metodoPago;
  final DateTime fecha;

  Venta({
    required this.productos,
    required this.metodoPago,
    required this.fecha,
  });

  double get subtotal {
    return productos.fold(
        0, (subtotal, producto) => subtotal + producto.precio);
  }

  double get total {
    return subtotal;
  }

  Map<String, dynamic> toMap() {
    return {
      'productos': productos.map((producto) => producto.toMap()).toList(),
      'metodoPago': metodoPago,
      'fecha': fecha,
    };
  }
}

class HistorialVentas extends StatefulWidget {
  @override
  _HistorialVentasState createState() => _HistorialVentasState();
}

class _HistorialVentasState extends State<HistorialVentas> {
  CollectionReference historialCollection =
      FirebaseFirestore.instance.collection('historialventas');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            color: Colors.black,
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VendedorHome()),
              );
            },
          ),
          title: const Text(
            'Historial de Ventas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 24.0,
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blueAccent, Colors.indigoAccent],
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: historialCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              List<Venta> historial = snapshot.data!.docs.map((document) {
                Map<String, dynamic>? data =
                    document.data() as Map<String, dynamic>?;

                if (data != null) {
                  List<dynamic>? productosData = data['productos'];

                  List<Producto> productos = productosData != null
                      ? productosData
                          .map((productoData) => Producto(
                                nombre: productoData['nombre'],
                                precio: productoData['precio'],
                              ))
                          .toList()
                      : [];

                  return Venta(
                    productos: productos,
                    metodoPago: data['metodoPago'],
                    fecha: (data['fecha'] as Timestamp).toDate(),
                  );
                } else {
                  return Venta(
                    productos: [],
                    metodoPago: '',
                    fecha: DateTime.now(),
                  );
                }
              }).toList();

              historial.sort((a, b) =>
                  a.fecha.compareTo(b.fecha)); // Ordena por fecha ascendente

              return ListView.builder(
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  Venta venta = historial[index];
                  int numeroVenta = index + 1;

                  return Card(
                    elevation: 4.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Venta #${numeroVenta}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Método de pago: ${venta.metodoPago}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Fecha: ${venta.fecha}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Subtotal: \$${venta.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Total: \$${venta.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                            ),
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
      ),
    );
  }
}

void main() {
  runApp(HistorialVentas());
}
