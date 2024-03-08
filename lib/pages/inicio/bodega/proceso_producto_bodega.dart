import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Inicialización de materialesNecesarios
  var materialesNecesarios = {
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
    'Bloque de 10cm alivianado': {'Cemento': 36},
    'Bloque de 10cm estructural': {'Cemento': 36},
    'Bloque de 15cm alivianado': {'Cemento': 36},
    'Bloque de 15cm estructural': {'Cemento': 36},
    'Bloque de 20cm alivianado': {'Cemento': 36},
    'Bloque de 20cm estructural': {'Cemento': 36},
    'Bloque de anclaje': {'Cemento': 36},
    'Postes de alambrado 1.60m': {'Cemento': 36},
    'Postes de alambrado 2m': {'Cemento': 36},
    'Tapas para canaleta': {'Cemento': 36},
    'Barilla': {'Cemento': 36}
  };

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
                    List<DataRow> rows = [];

                    for (int i = 0; i < data.length; i++) {
                      final cantidad = data[i]['cantidad'];
                      final nombre = data[i]['nombre'];
                      final descripcion = data[i]['descripcion'];
                      rows.add(
                        DataRow(
                          cells: [
                            DataCell(Text(nombre)),
                            DataCell(Text(descripcion)),
                            DataCell(Text(cantidad.toString())),
                          ],
                        ),
                      );
                    }

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
                    items: materialesNecesarios.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedProduct = value;
                          _cantidad =
                              materialesNecesarios[value]!['Cemento'] ?? 0;
                        });

                        _showMaterialsRequiredDialog(context, value);
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
      'Bloque de 10cm alivianado': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 10cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 15cm alivianado': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 15cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 20cm alivianado': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de 20cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Bloque de anclaje': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Postes de alambrado 1.60m': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Postes de alambrado 2m': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
      'Tapas para canaleta': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
    };

    if (materialesNecesarios.containsKey(selectedProduct)) {
      Map<String, int> materiales = materialesNecesarios[selectedProduct] ?? {};

      String message = 'Materiales necesarios:\n';
      materiales.forEach((material, cantidad) {
        message += '$cantidad Voqueta de $material\n';
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

void _producirProducto(
    BuildContext context, String? selectedProduct, String cantidad) {
  if (cantidad.isNotEmpty) {
    int cantidadInt = int.tryParse(cantidad) ?? 0;
    if (cantidadInt > 0) {
      Map<String, Map<String, int>> materialesNecesarios = {
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
        'Bloque de 10cm alivianado': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de 10cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de 15cm alivianado': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de 15cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de 20cm alivianado': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de 20cm estructural': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Bloque de anclaje': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Postes de alambrado 1.60m': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Postes de alambrado 2m': {'Piedra': 1, 'Arena': 1, 'Cemento': 36},
        'Tapas para canaleta': {'Piedra': 1, 'Arena': 1, 'Cemento': 36}
      };

      if (materialesNecesarios.containsKey(selectedProduct)) {
        FirebaseFirestore.instance.collection('procesoproducto').add({
          'nombre': selectedProduct,
          'cantidad': cantidadInt,
          'descripcion': "En proceso",
          'fecha': DateTime.now().toString().substring(0, 10),
        }).then((_) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Éxito'),
                content:
                    const Text('El producto se ha producido exitosamente.'),
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
