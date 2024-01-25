// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';

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
      home: const Estadistica(),
    );
  }
}

class Estadistica extends StatefulWidget {
  const Estadistica({Key? key}) : super(key: key);

  @override
  _EstadisticaState createState() => _EstadisticaState();
}

class _EstadisticaState extends State<Estadistica> {
  final CollectionReference historialVentasCollection =
      FirebaseFirestore.instance.collection('historial_ventas');

  List<Map<String, dynamic>> historialVentas = [];

  @override
  void initState() {
    super.initState();
    _loadHistorialVentas();
  }

  Future<void> _loadHistorialVentas() async {
    try {
      QuerySnapshot querySnapshot = await historialVentasCollection.get();
      setState(() {
        historialVentas = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error al cargar datos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas de Ventas'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (historialVentas.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return charts.PieChart(
        _createChartData(),
        animate: true,
      );
    }
  }

  List<charts.Series<Map<String, dynamic>, String>> _createChartData() {
    // Agrupar y sumar las ventas por nombre
    Map<String, double> totalVentasPorNombre = {};

    for (var venta in historialVentas) {
      String metodoPago = venta['metodoPago'] ?? 'Sin Nombre';
      double total = venta['total'] ?? 0;

      totalVentasPorNombre.update(
          metodoPago, (existingTotal) => (existingTotal) + total,
          ifAbsent: () => total);
    }

    // Convertir los datos procesados a una lista de series para el gráfico
    List<charts.Series<Map<String, dynamic>, String>> seriesList = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Ventas',
        domainFn: (venta, _) => venta['metodoPago'] ?? 'Sin Nombre',
        measureFn: (venta, _) => totalVentasPorNombre[venta['metodoPago']] ?? 0,
        colorFn: (venta, _) =>
            charts.ColorUtil.fromDartColor(_getColorFor(venta['metodoPago'])),
        labelAccessorFn: (venta, _) =>
            '${venta['metodoPago']}: ${totalVentasPorNombre[venta['metodoPago']]}',
        data: totalVentasPorNombre.entries
            .map((entry) => {'metodoPago': entry.key, 'total': entry.value})
            .toList(),
      ),
    ];

    return seriesList;
  }

  Color _getColorFor(String metodoPago) {
    // Define colors for each method of payment
    if (metodoPago == 'Efectivo') {
      return Colors.green;
    } else if (metodoPago == 'Tarjeta') {
      return const Color.fromARGB(255, 3, 10, 15);
    } else {
      return Colors.grey; // Default color for unknown payment methods
    }
  }
}
