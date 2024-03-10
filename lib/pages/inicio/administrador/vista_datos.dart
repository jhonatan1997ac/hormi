// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, deprecated_member_use

import 'dart:io';

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
                  buildCard(
                    context,
                    collectionTitle: 'Pedidos          ',
                    collectionName: 'pedidorealizado',
                    iconData: Icons.shopping_cart,
                    color: Colors.green,
                  ),
                  buildCard(
                    context,
                    collectionTitle: 'Proceso de Producto',
                    collectionName: 'procesoproducto',
                    iconData: Icons.build,
                    color: Colors.orange,
                  ),
                  buildCard(
                    context,
                    collectionTitle: 'Productos Terminados',
                    collectionName: 'productoterminado',
                    iconData: Icons.check_circle,
                    color: Color.fromARGB(255, 34, 73, 95), // Cambiado a gris
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 173, 106, 106), // Cambiado a gris
                ),
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.white, // Cambiado a blanco
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(BuildContext context,
      {required String collectionTitle,
      required String collectionName,
      required IconData iconData,
      required Color color}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      color: color,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaginaDatosFirestore(
                nombreColeccion: collectionName,
                tituloColeccion: collectionTitle,
              ),
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
                collectionTitle,
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

class PaginaDatosFirestore extends StatefulWidget {
  final String nombreColeccion;
  final String tituloColeccion;

  const PaginaDatosFirestore({
    Key? key,
    required this.nombreColeccion,
    required this.tituloColeccion,
  }) : super(key: key);

  @override
  _PaginaDatosFirestoreState createState() => _PaginaDatosFirestoreState();
}

class _PaginaDatosFirestoreState extends State<PaginaDatosFirestore> {
  late DateTime _selectedDate;
  late Stream<QuerySnapshot<Map<String, dynamic>>> _stream;
  late List<QueryDocumentSnapshot>
      _filteredDocuments; // Lista de documentos filtrados

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _stream = FirebaseFirestore.instance
        .collection(widget.nombreColeccion)
        .snapshots();
    _filteredDocuments = []; // Inicializa la lista de documentos filtrados
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tituloColeccion),
        actions: [
          IconButton(
            onPressed: () async {
              await _generateAndSavePDF(
                  _filteredDocuments); // Pasa los documentos filtrados al método
            },
            icon: const Icon(Icons.picture_as_pdf),
          ),
          if (widget.nombreColeccion !=
              'productoterminado') // Evitar el filtro para 'productoterminado'
            IconButton(
              onPressed: () {
                _selectDate(context);
              },
              icon:
                  Icon(Icons.calendar_today), // Cambiado a icono de calendario
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
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

          final fieldNames = getColumnHeaders(widget.nombreColeccion);
          final rows = getRows(documents, fieldNames);

          // Actualiza los documentos filtrados con los documentos actuales
          _filteredDocuments = documents;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _stream = FirebaseFirestore.instance
            .collection(widget.nombreColeccion)
            .where('fecha', isGreaterThanOrEqualTo: _selectedDate)
            .where('fecha', isLessThan: _selectedDate.add(Duration(days: 1)))
            .snapshots();
      });
    }
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
      return ['fecha', 'nombre', 'descripcion', 'cantidad'];
    } else if (nombreColeccion == 'productoterminado') {
      return ['nombre', 'precio', 'calidad', 'cantidad'];
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

  Future<void> _generateAndSavePDF(
      List<QueryDocumentSnapshot> documents) async {
    final List<String> columnHeaders = getColumnHeaders(widget.nombreColeccion);
    final rows = getRows(documents, columnHeaders);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text(widget.tituloColeccion)),
          pw.Table.fromTextArray(
            headers: columnHeaders,
            data: rows,
          ),
        ],
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File("${output!.path}/${widget.tituloColeccion}.pdf");
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }
}
