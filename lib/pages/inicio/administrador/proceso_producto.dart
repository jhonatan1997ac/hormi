// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, sort_child_properties_last

import 'package:apphormi/pages/inicio/administrador/Agregacion/agregar_producto_administrador.dart';
import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    title: 'Material Availability',
    initialRoute: '/',
    routes: {
      '/procesoproductos': (context) => DisponibilidadMaterialScreen(),
    },
  ));
}

class DisponibilidadMaterialScreen extends StatefulWidget {
  const DisponibilidadMaterialScreen({super.key});

  @override
  _DisponibilidadMaterialScreenState createState() =>
      _DisponibilidadMaterialScreenState();
}

class _DisponibilidadMaterialScreenState
    extends State<DisponibilidadMaterialScreen> {
  String? _selectedProduct;
  int _cantidad = 0;

  @override
  Widget build(BuildContext context) {
    _selectedProduct ??= ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proceso del producto',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('disponibilidadmaterial')
                      .orderBy('nombre')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final data = snapshot.data!.docs;
                    Map<String, int> availabilityMap = {};

                    for (int i = 0; i < data.length; i++) {
                      final cantidad = data[i]['cantidad'];
                      final nombre = data[i]['nombre'];
                      availabilityMap.update(nombre, (value) => cantidad,
                          ifAbsent: () => cantidad);
                    }

                    List<DataRow> rows = [];

                    availabilityMap.forEach((nombre, cantidad) {
                      rows.add(
                        DataRow(
                          cells: [
                            DataCell(Text(nombre)),
                            const DataCell(Text('Volqueta')),
                            DataCell(Text(cantidad.toString())),
                          ],
                        ),
                      );
                    });

                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Descripción')),
                        DataColumn(label: Text('Cantidad')),
                      ],
                      rows: rows,
                    );
                  },
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedProduct,
                    items: cantidadesPredeterminadas.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedProduct = value;
                          _cantidad = cantidadesPredeterminadas[value] ?? 0;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Seleccione su producto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _cantidad != 0
                        ? () {
                            if (_cantidad != 0) {
                              _producirProducto(context, _selectedProduct,
                                  _cantidad.toString());
                              Navigator.pushNamed(context, '/procesoproductos');
                            }
                          }
                        : null,
                    child: const Text('Producir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _cantidad != 0 ? Colors.blue : Colors.grey,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _producirProducto(
    BuildContext context, String? selectedProduct, String cantidad) {
  if (cantidad.isNotEmpty) {
    int cantidadInt = int.tryParse(cantidad) ?? 0;
    if (cantidadInt > 0) {
      if (kDebugMode) {
        print('Se van a producir $cantidadInt unidades de $selectedProduct');
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('La cantidad debe ser mayor que cero.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('La cantidad no puede estar vacía.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}