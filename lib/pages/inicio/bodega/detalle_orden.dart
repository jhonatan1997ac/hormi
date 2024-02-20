// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MaterialApp(
    home: DetalleOrdenes(),
  ));
}

class DetalleOrdenesModel {
  String idDetalle;
  String idOrden;
  String idProducto;
  dynamic cantidad;

  DetalleOrdenesModel({
    required this.idDetalle,
    required this.idOrden,
    required this.idProducto,
    required this.cantidad,
  });

  factory DetalleOrdenesModel.fromMap(Map<String, dynamic> map) {
    return DetalleOrdenesModel(
      idDetalle: map['idDetalle'].toString(),
      idOrden: map['idOrden'].toString(),
      idProducto: map['idProducto'].toString(),
      cantidad: map['cantidad'],
    );
  }
}

class DetalleOrdenes extends StatefulWidget {
  const DetalleOrdenes({Key? key});

  @override
  _DetalleOrdenesState createState() => _DetalleOrdenesState();
}

class _DetalleOrdenesState extends State<DetalleOrdenes> {
  late Stream<String> idOrdenSeleccionado;
  late List<OrdenModel> ordenes;

  final TextEditingController idDetalleController = TextEditingController();
  final TextEditingController idProductoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController nombreArchivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    idOrdenSeleccionado = Stream.value("Sin selección");
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    FirebaseFirestore.instance
        .collection('ordenes')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      setState(() {
        ordenes = querySnapshot.docs
            .map(
              (doc) => OrdenModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();
      });
    });
  }

  Future<bool> _requestPermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      if (kDebugMode) {
        print('Permisos de almacenamiento otorgados correctamente');
      }
      return true;
    } else {
      if (status.isPermanentlyDenied) {
        if (kDebugMode) {
          print('Permisos de almacenamiento denegados permanentemente');
        }
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Permisos de almacenamiento necesarios'),
            content: const Text(
                'Por favor, habilite los permisos de almacenamiento para guardar archivos.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Configuración'),
                onPressed: () {
                  openAppSettings();
                },
              ),
            ],
          ),
        );
      }
      return false;
    }
  }

  Future<void> generatePDF(List<DetalleOrdenesModel> detalleOrdenes) async {
    final pdf = pw.Document();
    final directory = await path_provider.getExternalStorageDirectory();
    final fileName = nombreArchivoController.text.isEmpty
        ? 'detalle_ordenes.pdf'
        : '${nombreArchivoController.text}.pdf';
    final file = File("${directory!.path}/$fileName");

    pdf.addPage(
      pw.MultiPage(
        build: (context) => detalleOrdenes
            .map(
              (detalleOrden) => pw.Container(
                margin: pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ID Detalle: ${detalleOrden.idDetalle}'),
                    pw.Text('ID Orden: ${detalleOrden.idOrden}'),
                    pw.Text(
                        'Cantidad: ${_getCantidadText(detalleOrden.cantidad)}'),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );

    if (await _requestPermission()) {
      await file.writeAsBytes(await pdf.save());
      _showSnackBarWithDownloadLink(file.path);
    } else {
      if (kDebugMode) {
        print('El usuario no concedió permisos de almacenamiento');
      }
    }
  }

  void _showSnackBarWithDownloadLink(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF guardado en: $filePath'),
        action: SnackBarAction(
          label: 'Abrir',
          onPressed: () {
            OpenFile.open(filePath);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalle de Órdenes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
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
        child: StreamBuilder(
          stream: idOrdenSeleccionado,
          builder: (context, AsyncSnapshot<String?> idOrdenSnapshot) {
            if (idOrdenSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('detalleorden')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                var detalleOrdenes = snapshot.data!.docs
                    .map(
                      (doc) => DetalleOrdenesModel(
                        idDetalle: doc['idDetalle'].toString(),
                        idOrden: doc['idOrden'].toString(),
                        idProducto: doc['idProducto'].toString(),
                        cantidad: doc['cantidad'],
                      ),
                    )
                    .toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: detalleOrdenes.length,
                        itemBuilder: (context, index) {
                          var detalleOrden = detalleOrdenes[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              title:
                                  Text('ID Detalle: ${detalleOrden.idDetalle}'),
                              subtitle: Text(
                                'ID Orden: ${detalleOrden.idOrden}\nCantidad: ${_getCantidadText(detalleOrden.cantidad)}',
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.picture_as_pdf_rounded),
                                onPressed: () async {
                                  if (await _requestPermission()) {
                                    await _showFileNameDialog(detalleOrden);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _showFileNameDialog(DetalleOrdenesModel detalleOrden) async {
    String? fileName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nombre del archivo'),
          content: TextField(
            controller: nombreArchivoController,
            decoration:
                InputDecoration(hintText: 'Ingrese el nombre del archivo'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                Navigator.of(context).pop(nombreArchivoController.text);
              },
            ),
          ],
        );
      },
    );

    if (fileName != null && fileName.isNotEmpty) {
      generatePDF([detalleOrden]);
    }
  }

  String _getCantidadText(cantidad) {
    return cantidad.toString();
  }
}

class OrdenModel {
  String id;
  String nombre;

  OrdenModel({
    required this.id,
    required this.nombre,
  });

  factory OrdenModel.fromMap(Map<String, dynamic> map) {
    return OrdenModel(
      id: map['id'].toString(),
      nombre: map['nombre'].toString(),
    );
  }
}
