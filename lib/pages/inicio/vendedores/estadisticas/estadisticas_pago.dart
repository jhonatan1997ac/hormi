// ignore_for_file: library_private_types_in_public_api, unnecessary_string_interpolations

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
      home: const Estadisticapago(),
    );
  }
}

class Estadisticapago extends StatefulWidget {
  const Estadisticapago({Key? key}) : super(key: key);

  @override
  _EstadisticapagoState createState() => _EstadisticapagoState();
}

class _EstadisticapagoState extends State<Estadisticapago> {
  final CollectionReference historialVentasCollection =
      FirebaseFirestore.instance.collection('historialventas');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas por tipo de pago'),
      ),
      body: Stack(
        children: [
          _buildBody(),
          _buildText(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
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
          List<Map<String, dynamic>> historialVentas = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return Column(
            children: [
              Expanded(
                child: charts.PieChart(
                  _createChartData(historialVentas),
                  animate: true,
                ),
              ),
              _buildIndicators(historialVentas),
            ],
          );
        }
      },
    );
  }

  Widget _buildIndicators(List<Map<String, dynamic>> historialVentas) {
    Map<String, double> totalVentasPorTipoPago = {
      'Efectivo': 0,
      'Banca Móvil': 0,
    };

    for (var venta in historialVentas) {
      String metodoPago = venta['metodoPago'] ?? 'Sin Nombre';
      double total = venta['total'] ?? 0;

      totalVentasPorTipoPago.update(
          metodoPago, (existingTotal) => (existingTotal) + total,
          ifAbsent: () => total);
    }

    double totalVentas = totalVentasPorTipoPago.values.reduce((a, b) => a + b);
    double porcentajeEfectivo =
        (totalVentasPorTipoPago['Efectivo'] ?? 0) / totalVentas * 100;
    double porcentajeBancaMovil =
        (totalVentasPorTipoPago['Banca Móvil'] ?? 0) / totalVentas * 100;

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Porcentaje de Ventas por Tipo de Pago:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildIndicator(
                  const Color.fromARGB(255, 3, 10, 15), 'Banca Móvil'),
              const SizedBox(width: 100),
              _buildIndicator(Colors.green, 'Efectivo'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
              'Porcentaje Efectivo: ${porcentajeEfectivo.toStringAsFixed(2)}%'),
          const SizedBox(height: 16),
          Text(
              'Porcentaje Banca Móvil: ${porcentajeBancaMovil.toStringAsFixed(2)}%'),
        ],
      ),
    );
  }

  Widget _buildIndicator(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text('$label'),
      ],
    );
  }

  Widget _buildText() {
    return const Positioned(
      top: 50,
      left: 16,
      child: Text(
        'Cual es el tipo de pago que se usa mas ?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<charts.Series<Map<String, dynamic>, String>> _createChartData(
      List<Map<String, dynamic>> historialVentas) {
    Map<String, double> totalVentasPorNombre = {};

    for (var venta in historialVentas) {
      String metodoPago = venta['metodoPago'] ?? 'Sin Nombre';
      double total = venta['total'] ?? 0;

      totalVentasPorNombre.update(
          metodoPago, (existingTotal) => (existingTotal) + total,
          ifAbsent: () => total);
    }

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
    if (metodoPago == 'Efectivo') {
      return Colors.green;
    } else if (metodoPago == 'Banca Móvil') {
      return const Color.fromARGB(255, 3, 10, 15);
    } else {
      return Colors.grey;
    }
  }
}
