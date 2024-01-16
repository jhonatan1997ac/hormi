import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

class Producto {
  final String nombre;
  final double precio;
  final String? imagen;

  Producto({required this.nombre, required this.precio, this.imagen});
}

class HistorialVenta {
  final List<Producto> productos;
  final String metodoPago;
  final DateTime fecha;

  HistorialVenta({
    required this.productos,
    required this.metodoPago,
    required this.fecha,
  });

  List<dynamic> toCsv() {
    return [
      fecha.toIso8601String(),
      metodoPago,
      productos.map((producto) => producto.nombre).join(', '),
      productos.map((producto) => producto.precio).join(', '),
      productos.map((producto) => producto.imagen ?? '').join(', '),
    ];
  }
}

class CalculosVenta {
  static void guardarVentaEnHistorial(HistorialVenta venta) {
    FirebaseFirestore.instance
        .collection('historial_ventas')
        .add({
          'productos': venta.productos
              .map((producto) => {
                    'nombre': producto.nombre,
                    'precio': producto.precio,
                    'imagen': producto.imagen,
                  })
              .toList(),
          'metodoPago': venta.metodoPago,
          'fecha': venta.fecha,
        })
        .then((value) => print("Venta guardada en historial"))
        .catchError((error) => print("Error al guardar la venta: $error"));
  }

  static Future<void> exportarHistorialAVentas(
      List<HistorialVenta> historial) async {
    try {
      final directory = await getExternalStorageDirectory();
      final path = directory!.path;
      final File file = File('$path/historial_ventas.csv');

      String csvData = const ListToCsvConverter()
          .convert(historial.map((venta) => venta.toCsv()).toList());

      await file.writeAsString(csvData);

      print(
          'Historial de ventas exportado correctamente a $path/historial_ventas.csv');
    } catch (e) {
      print('Error al exportar el historial de ventas: $e');
    }
  }

  static Stream<QuerySnapshot> obtenerHistorialVentas() {
    return FirebaseFirestore.instance
        .collection('historial_ventas')
        .orderBy('fecha', descending: true)
        .snapshots();
  }
}

class HistorialVentas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Ventas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historial de Ventas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: CalculosVenta.obtenerHistorialVentas(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var historial = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: historial.length,
                      itemBuilder: (context, index) {
                        var data =
                            historial[index].data() as Map<String, dynamic>;
                        var fecha = data['fecha'].toDate();
                        var metodoPago = data['metodoPago'];
                        var productosData = data['productos'];

                        // Convertir la lista de Map a una lista de Producto
                        List<Producto> productos = productosData
                            .map<Producto>((producto) => Producto(
                                  nombre: producto['nombre'],
                                  precio: producto['precio'],
                                  imagen: producto['imagen'],
                                ))
                            .toList();

                        // Crear una lista de Widgets ListTile para mostrar las ventas
                        List<Widget> ventas = productos
                            .map<Widget>((producto) => ListTile(
                                  title: Text('Producto: ${producto.nombre}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Precio: \$${producto.precio}'),
                                      if (producto.imagen != null)
                                        Image.network(
                                          producto.imagen!,
                                          width: 50.0,
                                        ),
                                    ],
                                  ),
                                ))
                            .toList();

                        // Aquí puedes personalizar la visualización de cada venta
                        // según la estructura de tu modelo de datos.
                        return Card(
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fecha: $fecha'),
                                Text('Método de Pago: $metodoPago'),
                                ...ventas,
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        'Error al cargar el historial de ventas: ${snapshot.error}');
                  } else {
                    return CircularProgressIndicator();
                  }
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
  runApp(MaterialApp(
    home: HistorialVentas(),
  ));
}
