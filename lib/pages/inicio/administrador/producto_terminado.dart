// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, sort_child_properties_last, unused_element

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    title: 'Material Availability',
    home: DisponibilidadMaterialScreen(),
  ));
}

class DisponibilidadMaterialScreen extends StatefulWidget {
  @override
  _DisponibilidadMaterialScreenState createState() =>
      _DisponibilidadMaterialScreenState();
}

class _DisponibilidadMaterialScreenState
    extends State<DisponibilidadMaterialScreen> {
  String _selectedProduct = '';
  int _cantidad = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disponibilidad de Material',
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
              MaterialPageRoute(builder: (context) => const Bodeguero()),
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
                    value:
                        _selectedProduct.isNotEmpty ? _selectedProduct : null,
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
                            _producirProducto(context, _selectedProduct,
                                _cantidad.toString());
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

  void _producirProducto(
      BuildContext context, String producto, String descripcion) {
    CollectionReference disponibilidadMaterialRef =
        FirebaseFirestore.instance.collection('disponibilidadmaterial');
    CollectionReference productosTerminadosRef =
        FirebaseFirestore.instance.collection('productosterminados');
    disponibilidadMaterialRef
        .where('nombre', isEqualTo: 'Arena')
        .get()
        .then((QuerySnapshot arenaSnapshot) {
      int cantidadArena = 0;
      if (arenaSnapshot.docs.isNotEmpty) {
        cantidadArena =
            int.tryParse(arenaSnapshot.docs.first['cantidad'].toString()) ?? 0;
      }

      disponibilidadMaterialRef
          .where('nombre', isEqualTo: 'Ripio')
          .get()
          .then((QuerySnapshot ripioSnapshot) {
        int cantidadRipio = 0;
        if (ripioSnapshot.docs.isNotEmpty) {
          cantidadRipio =
              int.tryParse(ripioSnapshot.docs.first['cantidad'].toString()) ??
                  0;
        }
        if (cantidadArena > 1 && cantidadRipio > 1) {
          // Modificación aquí
          disponibilidadMaterialRef.doc(arenaSnapshot.docs.first.id).update({
            'cantidad': cantidadArena - 1,
          });
          disponibilidadMaterialRef.doc(ripioSnapshot.docs.first.id).update({
            'cantidad': cantidadRipio - 1,
          });
          productosTerminadosRef.add({
            'nombre': producto,
            'descripcion': 'En proceso',
            'cantidad': descripcion,
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Producto producido con éxito'),
            ));
          }).catchError((error) {
            if (kDebugMode) {
              print("Error al agregar el productos terminados: $error");
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Advertencia: La cantidad de arena y/o ripio es baja. El producto se producirá, pero considera realizar un pedido pronto.'),
          ));

          disponibilidadMaterialRef.doc(arenaSnapshot.docs.first.id).update({
            'cantidad': cantidadArena - 1,
          });
          disponibilidadMaterialRef.doc(ripioSnapshot.docs.first.id).update({
            'cantidad': cantidadRipio - 1,
          });

          productosTerminadosRef.add({
            'nombre': producto,
            'descripcion': 'En proceso',
            'cantidad': descripcion,
          }).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Producto producido con éxito'),
            ));
          }).catchError((error) {
            if (kDebugMode) {
              print("Error al agregar el productos terminados: $error");
            }
          });
        }
      }).catchError((error) {
        if (kDebugMode) {
          print("Error al obtener ripio documents: $error");
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al producir el producto'),
        ));
      });
    }).catchError((error) {
      if (kDebugMode) {
        print("Error al obtener arena documents: $error");
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error al producir el producto'),
      ));
    });
  }

  void _mostrarAlertaPedido(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Realizar pedido'),
          content: const Text(
            'La cantidad de arena y/o ripio es baja. Considera realizar un pedido.',
          ),
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

const Map<String, int> cantidadesPredeterminadas = {
  'Adoquin clasico vehicular sin color': 3034,
  'Adoquin clasico vehicular con color': 3034,
  'Adoquin jaboncillo vehicular sin color': 7585,
  'Adoquin jaboncillo vehicular con color': 7585,
  'Adoquin paleta vehicular sin color': 5612,
  'Adoquin paleta vehicular con color': 5612,
  'Bloque de 10cm alivianado': 1050,
  'Bloque de 10cm estructural': 1050,
  'Bloque de 15cm alivianado': 800,
  'Bloque de 15cm estructural': 800,
  'Postes de alambrado 1.60m': 504,
  'Postes de alambrado 2m': 396,
  'Bloque de anclaje': 468,
  'Tapas para canaleta 1.50 x 0.30': 234,
};
