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

  // Calcula el subtotal de la venta
  double get subtotal {
    return productos.fold(
        0, (subtotal, producto) => subtotal + producto.precio);
  }

  // Calcula el total de la venta, puedes ajustar esto según tus necesidades
  double get total {
    // Agrega aquí cualquier otro cálculo necesario para el total
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
      debugShowCheckedModeBanner:
          false, // Oculta la etiqueta de depuración en la parte superior derecha
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navegar a la página anterior (puedes ajustar esto según tu estructura de navegación)
              Navigator.pop(context);
            },
          ),
          title: Text('Historial de Ventas'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: historialCollection.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
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

            // Ordenar el historial por fecha de forma descendente
            historial.sort((a, b) => b.fecha.compareTo(a.fecha));

            return ListView.builder(
              itemCount: historial.length,
              itemBuilder: (context, index) {
                Venta venta = historial[index];
                // Agregamos 1 al índice para mostrar el número de venta desde 1 en lugar de 0
                int numeroVenta = index + 1;

                return Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.blue,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Venta #${numeroVenta}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Método de pago: ${venta.metodoPago}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Fecha: ${venta.fecha}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Subtotal: \$${venta.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Total: \$${venta.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12.0,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

void main() {
  runApp(HistorialVentas());
}
