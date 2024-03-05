// ignore_for_file: deprecated_member_use, use_key_in_widget_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Datos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VistaDatos(),
    );
  }
}

class VistaDatos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vista de datos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Administrador()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                children: <Widget>[
                  buildCard(context, 'Pedidos Realizados', 'pedidorealizado',
                      Icons.shopping_cart, Colors.green),
                  buildCard(context, 'Proceso de Producto', 'procesoproducto',
                      Icons.build, Colors.orange),
                  buildCard(context, 'Productos Terminados',
                      'productoterminado', Icons.check_circle, Colors.blue),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Cerrar la aplicación
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context, String cardTitle,
      String collectionName, IconData iconData, Color color) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: color,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PaginaDatosFirestore(nombreColeccion: collectionName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                iconData,
                size: 48,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                cardTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaginaDatosFirestore extends StatelessWidget {
  final String nombreColeccion;

  const PaginaDatosFirestore({Key? key, required this.nombreColeccion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nombreColeccion),
        actions: [
          IconButton(
            onPressed: () async {
              final List<String> columnHeaders =
                  getColumnHeaders(nombreColeccion);
              final documents = await FirebaseFirestore.instance
                  .collection(nombreColeccion)
                  .get();
              final rows = getRows(documents.docs, columnHeaders);
              await generateAndSavePDF(
                  context, nombreColeccion, columnHeaders, rows);
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection(nombreColeccion).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return const Text('No hay datos disponibles');
          }

          final fieldNames = getColumnHeaders(nombreColeccion);
          final rows = getRows(documents, fieldNames);

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 55, 111, 139),
                      Color.fromARGB(255, 83, 32, 32),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    DataTable(
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.blue.shade300),
                      dataRowColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                      columns: fieldNames.map((fieldName) {
                        return DataColumn(label: Text(fieldName));
                      }).toList(),
                      rows: rows.map((rowData) {
                        return DataRow(
                            cells: rowData.map((cellData) {
                          return DataCell(Text(cellData.toString()));
                        }).toList());
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> getColumnHeaders(String nombreColeccion) {
    if (nombreColeccion == 'pedidorealizado') {
      return [
        'fecha',
        'precio',
        'diasNecesarios',
        'idpedido',
        'cantidad',
        'nombre',
        'calidad',
      ];
    } else if (nombreColeccion == 'procesoproducto') {
      return ['nombre', 'descripcion', 'cantidad'];
    } else if (nombreColeccion == 'productoterminado') {
      return [
        'idproductoterminado',
        'imagen',
        'precio',
        'calidad',
        'cantidad',
        'disponible',
        'nombre'
      ];
    } else {
      return [];
    }
  }

  List<List<dynamic>> getRows(
      List<QueryDocumentSnapshot> documents, List<String> fieldNames) {
    List<List<dynamic>> rows = [];

    for (var document in documents) {
      final data = document.data() as Map<String, dynamic>;
      List<dynamic> rowData = [];

      for (var fieldName in fieldNames) {
        if (fieldName == 'imagen') {
          rowData.add(data[fieldName].toString());
        } else if (fieldName == 'fecha' && data[fieldName] is Timestamp) {
          final date = (data[fieldName] as Timestamp).toDate();
          final formattedDate = DateFormat('dd/MM/yyyy').format(date);
          rowData.add(formattedDate);
        } else {
          rowData.add(data[fieldName].toString());
        }
      }

      rows.add(rowData);
    }

    return rows;
  }

  Future<void> generateAndSavePDF(BuildContext context, String title,
      List<String> columnHeaders, List<List<dynamic>> rows) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(title)),
          pw.Table.fromTextArray(
            headers: columnHeaders,
            data: rows,
          ),
        ],
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/$title.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }
}
