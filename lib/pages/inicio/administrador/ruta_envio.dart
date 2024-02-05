import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class RutaEnvio extends StatefulWidget {
  const RutaEnvio({Key? key});

  @override
  _RutaEnvioState createState() => _RutaEnvioState();
}

class _RutaEnvioState extends State<RutaEnvio> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController idController = TextEditingController();
  TextEditingController origenController = TextEditingController();
  TextEditingController destinoController = TextEditingController();
  TextEditingController detallesEnvioController = TextEditingController();
  TextEditingController infoTransportistaController = TextEditingController();
  TextEditingController estadoEnvioController = TextEditingController();
  TextEditingController instruccionesController = TextEditingController();
  TextEditingController costosTarifasController = TextEditingController();
  TextEditingController documentacionController = TextEditingController();
  TextEditingController notasComentariosController = TextEditingController();

  Map<String, String> errores = {};

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ruta Envio ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Datos de Ruta Envio'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            const Icon(Icons.route),
            const SizedBox(width: 20),
            const Text(
              'Información sobre Ruta Envios',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildRutaenviosTable(),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _mostrarDialogoAgregarRutaenvio(context);
                },
                child: const Text('Agregar Rutaenvio'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRutaenviosTable() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore.collection('rutaenvio').orderBy('idrutaenvio').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var rutaenvios = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Origen')),
              DataColumn(label: Text('Destino')),
              DataColumn(label: Text('Detalles del Envío')),
              DataColumn(label: Text('Información del Transportista')),
              DataColumn(label: Text('Estado del Envío')),
              DataColumn(label: Text('Instrucciones Especiales')),
              DataColumn(label: Text('Costos y Tarifas')),
              DataColumn(label: Text('Documentación')),
              DataColumn(label: Text('Notas y Comentarios')),
            ],
            rows: rutaenvios.map((rutaenvio) {
              var id = rutaenvio['idrutaenvio'];
              var origen = rutaenvio['origen'];
              var destino = rutaenvio['destino'];
              var detallesEnvio = rutaenvio['detalles_envio'];
              var infoTransportista = rutaenvio['info_transportista'];
              var estadoEnvio = rutaenvio['estado_envio'];
              var instrucciones = rutaenvio['instrucciones'];
              var costosTarifas = rutaenvio['costos_tarifas'];
              var documentacion = rutaenvio['documentacion'];
              var notasComentarios = rutaenvio['notas_comentarios'];

              return DataRow(cells: [
                DataCell(Text(id)),
                DataCell(Text(origen)),
                DataCell(Text(destino)),
                DataCell(Text(detallesEnvio)),
                DataCell(Text(infoTransportista)),
                DataCell(Text(estadoEnvio)),
                DataCell(Text(instrucciones)),
                DataCell(Text(costosTarifas)),
                DataCell(Text(documentacion)),
                DataCell(Text(notasComentarios)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoAgregarRutaenvio(BuildContext context) async {
    errores.clear(); // Limpiar mensajes de error al abrir el diálogo

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Rutaenvio'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(Icons.route),
                    const SizedBox(width: 8),
                    const Text(
                      'Información sobre Rutaenvios',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildTextField('ID de la Rutaenvio', idController),
                    _buildTextField('Origen', origenController),
                    _buildTextField('Destino', destinoController),
                    _buildTextField(
                        'Detalles del Envío', detallesEnvioController),
                    _buildTextField('Información del Transportista',
                        infoTransportistaController),
                    _buildTextField('Estado del Envío', estadoEnvioController),
                    _buildTextField(
                        'Instrucciones Especiales', instruccionesController),
                    _buildTextField(
                        'Costos y Tarifas', costosTarifasController),
                    _buildTextField('Documentación', documentacionController),
                    _buildTextField(
                        'Notas y Comentarios', notasComentariosController),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    _validarCampos();
                    setState(() {}); // Actualizar el estado del diálogo
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            errorText: errores[label],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _validarCampos() {
    errores.clear();

    if (idController.text.isEmpty) {
      errores['ID de la Rutaenvio'] = 'Campo obligatorio';
    }
    if (origenController.text.isEmpty) {
      errores['Origen'] = 'Campo obligatorio';
    }
    if (destinoController.text.isEmpty) {
      errores['Destino'] = 'Campo obligatorio';
    }
    if (detallesEnvioController.text.isEmpty) {
      errores['Detalles del Envío'] = 'Campo obligatorio';
    }
    if (infoTransportistaController.text.isEmpty) {
      errores['Información del Transportista'] = 'Campo obligatorio';
    }
    if (estadoEnvioController.text.isEmpty) {
      errores['Estado del Envío'] = 'Campo obligatorio';
    }
    if (instruccionesController.text.isEmpty) {
      errores['Instrucciones Especiales'] = 'Campo obligatorio';
    }
    if (costosTarifasController.text.isEmpty) {
      errores['Costos y Tarifas'] = 'Campo obligatorio';
    }
    if (documentacionController.text.isEmpty) {
      errores['Documentación'] = 'Campo obligatorio';
    }
    if (notasComentariosController.text.isEmpty) {
      errores['Notas y Comentarios'] = 'Campo obligatorio';
    }

    setState(() {});

    if (errores.isEmpty) {
      _agregarRutaenvio();
      Navigator.of(context).pop();
    }
  }

  Future<void> _agregarRutaenvio() async {
    CollectionReference rutaenvioCollection =
        _firestore.collection('rutaenvio');

    String id = idController.text;

    // Verificar si el ID ya existe
    QuerySnapshot entradasExistente =
        await rutaenvioCollection.where('idrutaenvio', isEqualTo: id).get();

    if (entradasExistente.docs.isNotEmpty) {
      // El ID ya existe, mostrar un mensaje de error
      _mostrarMensajeError('Ya existe una rutaenvio con este ID.');
      return;
    }

    Map<String, dynamic> nuevaRutaenvio = {
      'idrutaenvio': id,
      'origen': origenController.text,
      'destino': destinoController.text,
      'detalles_envio': detallesEnvioController.text,
      'info_transportista': infoTransportistaController.text,
      'estado_envio': estadoEnvioController.text,
      'instrucciones': instruccionesController.text,
      'costos_tarifas': costosTarifasController.text,
      'documentacion': documentacionController.text,
      'notas_comentarios': notasComentariosController.text,
    };

    try {
      await rutaenvioCollection.add(nuevaRutaenvio);
      if (kDebugMode) {
        print('Rutaenvio agregada correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar Rutaenvio: $e');
      }
    }
  }

  void _mostrarMensajeError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const RutaEnvio();
  }
}