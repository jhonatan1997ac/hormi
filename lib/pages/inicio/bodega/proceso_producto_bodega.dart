// ignore_for_file: library_private_types_in_public_api, sort_child_properties_last, avoid_function_literals_in_foreach_calls, unnecessary_import

import 'package:apphormi/pages/inicio/administrador/Agregacion/agregar_producto_administrador.dart';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Material Availability',
    initialRoute: '/',
    routes: {
      '/elavoracionproductobode': (context) => const ProcesoProductoBode(),
    },
  ));
}

class ProcesoProductoBode extends StatefulWidget {
  const ProcesoProductoBode({Key? key}) : super(key: key);

  @override
  _ProcesoProductoBodeState createState() => _ProcesoProductoBodeState();
}

class _ProcesoProductoBodeState extends State<ProcesoProductoBode> {
  String? _selectedProduct;
  int _cantidad = 0;

  @override
  Widget build(BuildContext context) {
    _selectedProduct ??= ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Proceso del producto Bodega',
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
                              Navigator.pushNamed(
                                  context, '/elavoracionproductobode');
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
      List<String> productsToCheck = [
        'Adoquin clasico vehicular sin color',
        'Adoquin clasico vehicular con color',
        'Adoquin jaboncillo vehicular sin color',
        'Adoquin jaboncillo vehicular con color',
        'Adoquin paleta vehicular sin color',
        'Adoquin paleta vehicular con color',
        'Bloque de 10cm alivianado',
        'Bloque de 10cm estructural',
        'Bloque de 15cm alivianado',
        'Bloque de 15cm estructural',
        'Bloque de 20cm alivianado',
        'Bloque de 20cm estructural',
        'Bloque de anclaje',
        'Postes de alambrado 1.60m',
        'Postes de alambrado 2m',
        'Tapas para canaleta',
        'Barilla'
      ];

      // Verificar si el producto seleccionado está en la lista de productos a verificar
      if (productsToCheck.contains(selectedProduct)) {
        // Verificar la disponibilidad de Cemento, Piedra y Arena
        FirebaseFirestore.instance
            .collection('disponibilidadmaterial')
            .where('nombre', whereIn: ['Cemento', 'Piedra', 'Arena'])
            .get()
            .then((QuerySnapshot querySnapshot) {
              bool materialAvailable = true;
              querySnapshot.docs.forEach((doc) {
                int disponible = doc['cantidad'];
                if (disponible <= 0) {
                  materialAvailable = false;
                }
              });

              if (materialAvailable) {
                // Realizar la resta de una unidad para cada material
                querySnapshot.docs.forEach((doc) {
                  FirebaseFirestore.instance
                      .collection('disponibilidadmaterial')
                      .doc(doc.id)
                      .update({'cantidad': doc['cantidad'] - 1});
                });

                // Continuar con el proceso de producción
                _continuarProduccion(context, selectedProduct, cantidadInt);
              } else {
                // Mostrar mensaje de pedido de material
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Aviso'),
                      content: const Text(
                          'Se necesita hacer un pedido de material (Cemento, Piedra, Arena).'),
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
            });
      } else {
        // Si el producto no necesita verificación de cantidad, continuar con el proceso de producción
        _continuarProduccion(context, selectedProduct, cantidadInt);
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

void _continuarProduccion(
    BuildContext context, String? selectedProduct, int cantidadInt) {
  // Obtener la fecha actual en formato "yyyy-MM-dd"
  String formattedDate = DateTime.now().toString().substring(0, 10);

  // Crear un nuevo documento en la colección 'procesoproducto'
  FirebaseFirestore.instance.collection('procesoproducto').add({
    'nombre': selectedProduct,
    'cantidad': cantidadInt,
    'descripcion': "En proceso",
    // Utilizar formattedDate como la fecha
    'fecha': formattedDate,
  }).then((_) {
    // Mostrar un mensaje de éxito
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: const Text('El producto se ha producido exitosamente.'),
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
  }).catchError((error) {
    // Mostrar un mensaje de error si ocurre un error al agregar los datos
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Se produjo un error: $error'),
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
  });
}
