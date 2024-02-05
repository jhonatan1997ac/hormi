// ignore_for_file: unused_field, library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

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
      home: const FechaVentas(),
    );
  }
}

class FechaVentas extends StatefulWidget {
  const FechaVentas({Key? key}) : super(key: key);

  @override
  _FechaVentasState createState() => _FechaVentasState();
}

class _FechaVentasState extends State<FechaVentas> {
  final CollectionReference historialVentasCollection =
      FirebaseFirestore.instance.collection('historialventas');

  final List<Color> fixedColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Ventas'),
      ),
      body: Stack(
        children: [
          _buildBody(),
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

          // Actualizar eventos para el calendario
          _updateEvents(historialVentas);

          return Column(
            children: [
              TableCalendar(
                calendarFormat: _calendarFormat,
                focusedDay: _focusedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2101),
                headerStyle: const HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });

                  // Actualizar gráfico de pastel al seleccionar un día
                  _updatePieChart(selectedDay, historialVentas);
                },
                eventLoader: (day) => _events[day] ?? [],
              ),
              Expanded(
                child: charts.PieChart(
                  _createChartData(historialVentas),
                  animate: true,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void _updateEvents(List<Map<String, dynamic>> historialVentas) {
    _events = {};
    for (var venta in historialVentas) {
      Timestamp fecha = venta['fecha'];
      DateTime fechaVenta = fecha.toDate();
      String fechaStr = fechaVenta.toString().substring(0, 10);

      if (_events.containsKey(fechaVenta)) {
        _events[fechaVenta]!.add(fechaStr);
      } else {
        _events[fechaVenta] = [fechaStr];
      }
    }
  }

  void _updatePieChart(
      DateTime? selectedDay, List<Map<String, dynamic>> historialVentas) {
    if (selectedDay != null && _events.containsKey(selectedDay)) {
      // Formatear la fecha seleccionada
      String formattedSelectedDay = selectedDay.toString().substring(0, 10);

      // Filtrar el historial de ventas para el día seleccionado
      List<Map<String, dynamic>> ventasDelDia = historialVentas
          .where((venta) =>
              venta['fecha'].toDate().toString().substring(0, 10) ==
              formattedSelectedDay)
          .toList();

      // Verificar si hay un cambio en los datos antes de actualizar el gráfico
      if (!listEquals(_events[selectedDay], ventasDelDia)) {
        setState(() {
          _updateEvents(ventasDelDia);
        });
      }
    }
  }

  List<charts.Series<Map<String, dynamic>, String>> _createChartData(
      List<Map<String, dynamic>> historialVentas) {
    Map<String, double> totalVentasPorFecha = {};

    for (var venta in historialVentas) {
      Timestamp fecha = venta['fecha'];
      double total = venta['total'] ?? 0;
      String fechaStr = fecha.toDate().toString().substring(0, 10);

      totalVentasPorFecha.update(
          fechaStr, (existingTotal) => (existingTotal) + total,
          ifAbsent: () => total);
    }

    List<charts.Series<Map<String, dynamic>, String>> seriesList = [
      charts.Series<Map<String, dynamic>, String>(
        id: 'Ventas',
        domainFn: (venta, _) => venta['fecha'],
        measureFn: (venta, _) => totalVentasPorFecha[venta['fecha']] ?? 0,
        colorFn: (venta, _) => charts.ColorUtil.fromDartColor(
          fixedColors[
              totalVentasPorFecha.keys.toList().indexOf(venta['fecha']) %
                  fixedColors.length],
        ),
        labelAccessorFn: (venta, _) =>
            '${venta['fecha']}: ${totalVentasPorFecha[venta['fecha']]}',
        data: totalVentasPorFecha.entries
            .map((entry) => {'fecha': entry.key, 'total': entry.value})
            .toList(),
      ),
    ];

    return seriesList;
  }
}
