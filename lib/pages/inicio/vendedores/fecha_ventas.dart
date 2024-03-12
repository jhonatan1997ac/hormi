// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:apphormi/pages/inicio/vendedores/vendedor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estadísticas de Ventas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FechaVentas(),
    );
  }
}

class FechaVentas extends StatefulWidget {
  @override
  _FechaVentasState createState() => _FechaVentasState();
}

class _FechaVentasState extends State<FechaVentas> {
  final CollectionReference historialVentasCollection =
      FirebaseFirestore.instance.collection('historialventas');

  Map<DateTime, List<dynamic>> _events = {};
  late DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario de Ventas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const VendedorHome()));
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 55, 111, 139),
                  Color.fromARGB(255, 165, 160, 160),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildMonthYearPicker(),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: historialVentasCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        List<Map<String, dynamic>> historialVentas = snapshot
                            .data!.docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();

                        _updateEvents(historialVentas);

                        return _buildCalendar();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthYearPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedDate =
                  DateTime(_selectedDate.year, _selectedDate.month - 1);
            });
          },
        ),
        Column(
          children: [
            Text(
              _getMonthName(_selectedDate.month),
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
            Text(
              '${_selectedDate.year}',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _selectedDate =
                  DateTime(_selectedDate.year, _selectedDate.month + 1);
            });
          },
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }

  Widget _buildCalendar() {
    int daysInMonth =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        DateTime date =
            DateTime(_selectedDate.year, _selectedDate.month, index + 1);
        bool hasSales = _events.containsKey(date) && _events[date] != null;
        return GestureDetector(
          onTap: () {
            if (hasSales) {
              _showSalesInfoDialog(date, _events[date]!);
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: hasSales ? Colors.blueAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: hasSales ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateEvents(List<Map<String, dynamic>> historialVentas) {
    _events = {};
    for (var venta in historialVentas) {
      Timestamp fecha = venta['fecha'];
      DateTime fechaVenta = fecha.toDate();
      if (_events.containsKey(
          DateTime(fechaVenta.year, fechaVenta.month, fechaVenta.day))) {
        _events[DateTime(fechaVenta.year, fechaVenta.month, fechaVenta.day)]!
            .add(venta);
      } else {
        _events[DateTime(fechaVenta.year, fechaVenta.month, fechaVenta.day)] = [
          venta
        ];
      }
    }
  }

  void _showSalesInfoDialog(DateTime date, List<dynamic> salesInfo) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ventas para el ${date.day}/${date.month}/${date.year}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Información de ventas:',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                for (var venta in salesInfo)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total de ventas: ${venta['total']}'),
                      Text('Productos vendidos:',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      for (var producto in venta['productos'])
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${producto['cantidad']}',
                                style: TextStyle(color: Colors.black)),
                            Image.network(
                              producto['imagen'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            Text('Nombre: ${producto['nombre']}',
                                style: TextStyle(color: Colors.black)),
                            Text('Precio: ${producto['precio']}',
                                style: TextStyle(color: Colors.black)),
                            Text('ID del producto: ${producto['producto_id']}',
                                style: TextStyle(color: Colors.black)),
                            Divider(),
                          ],
                        ),
                      Divider(),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
