// ignore_for_file: library_private_types_in_public_api, sort_child_properties_last, avoid_function_literals_in_foreach_calls, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:apphormi/pages/inicio/administrador/Agregacion/agregar_producto_administrador.dart';
import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Material Availability',
    initialRoute: '/',
    routes: {
      '/procesoproductos': (context) => const DisponibilidadMaterialScreen(),
    },
  ));
}

class DisponibilidadMaterialScreen extends StatefulWidget {
  const DisponibilidadMaterialScreen({Key? key}) : super(key: key);

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
                    Map<String, Map<String, dynamic>> materialMap = {};

                    for (int i = 0; i < data.length; i++) {
                      final cantidad = data[i]['cantidad'];
                      final nombre = data[i]['nombre'];
                      final descripcion = data[i][
                          'descripcion']; // Agrega esta línea para recuperar la descripción
                      materialMap[nombre] = {
                        'cantidad': cantidad,
                        'descripcion': descripcion
                      }; // Actualiza la estructura del mapa
                    }

                    List<DataRow> rows = [];

                    materialMap.forEach((nombre, materialData) {
                      rows.add(
                        DataRow(
                          cells: [
                            DataCell(Text(nombre)),
                            DataCell(Text(materialData['descripcion'])),
                            DataCell(Text(materialData['cantidad'].toString())),
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
                          _showMaterialsRequiredDialog(context,
                              _selectedProduct); // Llamada a la función _showMaterialsRequiredDialog
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
                              _showMaterialsRequiredDialog(
                                  context, _selectedProduct);
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
      Map<String, Map<String, int>> productosRequeridos = {
        'Adoquin clasico vehicular sin color': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36
        },
        'Adoquin clasico vehicular con color': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36
        },
        'Adoquin jaboncillo vehicular sin color': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36
        },
        'Adoquin jaboncillo vehicular con color': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36
        },
        'Adoquin paleta vehicular sin color': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36
        },
        'Adoquin paleta vehicular con color': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36
        },
        'Bloque de 10cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de 15cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de anclaje': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Postes de alambrado 1.60m': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36,
          'Barilla': 576
        },
        'Postes de alambrado 2m': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36,
          'Barilla': 468
        },
        'Tapas para canaleta': {
          'Piedra': 1,
          'Arena': 1,
          'Cemento': 36,
          'Barilla': 234
        }
      };

      if (productosRequeridos.containsKey(selectedProduct)) {
        Map<String, int> materialesRequeridos =
            productosRequeridos[selectedProduct]!;
        bool materialesSuficientes = true;

        // Verificar la disponibilidad de cada material requerido
        Future.forEach(materialesRequeridos.entries, (entry) async {
          String material = entry.key;
          int cantidadRequerida = entry.value;

          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('disponibilidadmaterial')
              .where('nombre', isEqualTo: material)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            int cantidadDisponible = querySnapshot.docs[0]['cantidad'];
            if (cantidadDisponible < cantidadRequerida) {
              // Si el material no está disponible en la cantidad requerida, marcar como insuficiente
              materialesSuficientes = false;
            }
          } else {
            // Si el material no está en la base de datos, marcar como insuficiente
            materialesSuficientes = false;
          }
        }).then((_) {
          if (materialesSuficientes) {
            // Todos los materiales están disponibles en las cantidades requeridas, proceder con la producción
            _continuarProduccion(context, selectedProduct, cantidadInt);
          } else {
            // Algunos materiales no están disponibles en las cantidades requeridas, mostrar mensaje de pedido de material
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Aviso'),
                  content: const Text(
                      'Se necesita hacer un pedido de material para poder producir este producto.'),
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
        // El producto seleccionado no está en la lista de productos requeridos
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('El producto seleccionado no es válido.'),
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
      // La cantidad debe ser mayor que cero
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
    // La cantidad no puede estar vacía
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

void verificarCantidades(BuildContext context) {
  Map<String, Map<String, int>> productosRequeridos = {
    'Adoquin clasico vehicular sin color': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36
    },
    'Adoquin clasico vehicular con color': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36
    },
    'Adoquin jaboncillo vehicular sin color': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36
    },
    'Adoquin jaboncillo vehicular con color': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36
    },
    'Adoquin paleta vehicular sin color': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36
    },
    'Adoquin paleta vehicular con color': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36
    },
    'Bloque de 10cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
    'Bloque de 15cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
    'Bloque de anclaje': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
    'Postes de alambrado 1.60m': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36,
      'Barilla': 576
    },
    'Postes de alambrado 2m': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36,
      'Barilla': 468
    },
    'Tapas para canaleta': {
      'Piedra': 1,
      'Arena': 1,
      'Cemento': 36,
      'Barilla': 234
    }
  };
  int materialesInsuficientes = 0;
  int cantidadInt = 0;

  FirebaseFirestore.instance
      .collection('disponibilidadmaterial')
      .where('nombre', isEqualTo: 'Cemento')
      .get()
      .then((QuerySnapshot cementoSnapshot) {
    FirebaseFirestore.instance
        .collection('disponibilidadmaterial')
        .where('nombre', isEqualTo: 'Barilla')
        .get()
        .then((QuerySnapshot BarillaSnapshot) {
      // Verificar la disponibilidad de Cemento
      if (cementoSnapshot.docs.isNotEmpty && BarillaSnapshot.docs.isNotEmpty) {
        var selectedProduct;
        int cantidadRequeridaCemento =
            productosRequeridos[selectedProduct]!['Cemento'] ?? 0;
        int cantidadRequeridaBarilla =
            productosRequeridos[selectedProduct]!['Barilla'] ?? 0;

        int cantidadDisponibleCemento = cementoSnapshot.docs[0]['cantidad'];
        int cantidadDisponibleBarilla = BarillaSnapshot.docs[0]['cantidad'];

        if (cantidadRequeridaCemento <= cantidadDisponibleCemento &&
            cantidadRequeridaBarilla <= cantidadDisponibleBarilla) {
          // Restar la cantidad necesaria de cemento
          FirebaseFirestore.instance
              .collection('disponibilidadmaterial')
              .doc(cementoSnapshot.docs[0].id)
              .update({
            'cantidad': cantidadDisponibleCemento - cantidadRequeridaCemento
          });

          // Restar la cantidad necesaria de Barilla
          FirebaseFirestore.instance
              .collection('disponibilidadmaterial')
              .doc(BarillaSnapshot.docs[0].id)
              .update({
            'cantidad': cantidadDisponibleBarilla - cantidadRequeridaBarilla
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
                    'Se necesita hacer un pedido de material (Cemento, Barilla).'),
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
    });
  });

  // Verificar si hay materiales insuficientes
  if (materialesInsuficientes > 0) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text(
              'No se puede proceder con la producción debido a materiales insuficientes.'),
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

void _showMaterialsRequiredDialog(
    BuildContext context, String? selectedProduct) {
  if (selectedProduct != null) {
    Map<String, Map<String, int>> materialesNecesarios = {
      'Adoquin clasico vehicular sin color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin clasico vehicular con color': {
        'Piedra': 1,
        'cantidad': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin jaboncillo vehicular sin color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin jaboncillo vehicular con color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin paleta vehicular sin color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin paleta vehicular con color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Bloque de 10cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 15cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de anclaje': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Postes de alambrado 1.60m': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36,
        'Barilla': 576
      },
      'Postes de alambrado 2m': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36,
        'Barilla': 468
      },
      'Tapas para canaleta': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36,
        'Barilla': 234
      }
    };

    if (materialesNecesarios.containsKey(selectedProduct)) {
      Map<String, int> materiales = materialesNecesarios[selectedProduct] ?? {};

      String message = 'Materiales necesarios:\n';
      materiales.forEach((material, cantidad) {
        String unit = material == 'Cemento' || material == 'Barilla'
            ? 'Unidad'
            : 'Voqueta';
        message += '$cantidad $unit de $material\n';
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Materiales Necesarios para $selectedProduct'),
            content: Text(message),
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
    'fecha': formattedDate,
  }).then((_) {
    // Actualizar la cantidad de cada material en la base de datos
    var productosRequeridos = {
      'Adoquin clasico vehicular sin color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin clasico vehicular con color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin jaboncillo vehicular sin color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin jaboncillo vehicular con color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin paleta vehicular sin color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Adoquin paleta vehicular con color': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36
      },
      'Bloque de 10cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 15cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de anclaje': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Postes de alambrado 1.60m': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36,
        'Barilla': 576
      },
      'Postes de alambrado 2m': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36,
        'Barilla': 468
      },
      'Tapas para canaleta': {
        'Piedra': 1,
        'Arena': 1,
        'Cemento': 36,
        'Barilla': 234
      }
    };

    if (productosRequeridos.containsKey(selectedProduct)) {
      Map<String, int> materialesRequeridos =
          productosRequeridos[selectedProduct]!;
      bool materialesSuficientes = true;

      materialesRequeridos.forEach((material, cantidadRequerida) async {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('disponibilidadmaterial')
            .where('nombre', isEqualTo: material)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          int cantidadDisponible = querySnapshot.docs[0]['cantidad'];
          if (cantidadDisponible < cantidadRequerida) {
            materialesSuficientes = false;
            return;
          }
        } else {
          materialesSuficientes = false;
          return;
        }
      });

      if (materialesSuficientes) {
        // Restar la cantidad necesaria de cada material
        materialesRequeridos.forEach((material, cantidadRequerida) async {
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection('disponibilidadmaterial')
              .where('nombre', isEqualTo: material)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            DocumentSnapshot document = querySnapshot.docs[0];
            int cantidadActual = document['cantidad'];
            int nuevaCantidad = cantidadActual - cantidadRequerida;

            // Actualizar el documento con la nueva cantidad
            document.reference.update({'cantidad': nuevaCantidad});
          }
        });

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
      } else {
        // Mostrar mensaje de pedido de material
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Aviso'),
              content: const Text(
                  'Se necesita hacer un pedido de material para poder producir este producto.'),
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
      // El producto seleccionado no está en la lista de productos requeridos
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('El producto seleccionado no es válido.'),
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
