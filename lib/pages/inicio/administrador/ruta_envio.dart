// ignore_for_file: unused_element, use_key_in_widget_constructors, library_private_types_in_public_api, unused_import

import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Datos de Ruta Envio',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.route, color: Colors.black),
                    SizedBox(width: 20),
                    Text(
                      'Información sobre Ruta Envios',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Agregar Rutaenvio',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
          child: Container(
            color: Colors.white.withOpacity(0.8),
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
                DataColumn(
                  label: Text('Acciones'),
                ),
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
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _mostrarDialogoEditarRutaenvio(context, rutaenvio);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _eliminarRutaenvio(id);
                        },
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoAgregarRutaenvio(BuildContext context) async {
    errores.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Agregar Rutaenvio',
              ),
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
                    setState(() {});
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

  Future<void> _mostrarDialogoEditarRutaenvio(
      BuildContext context, DocumentSnapshot rutaenvio) async {
    idController.clear();
    origenController.clear();
    destinoController.clear();
    detallesEnvioController.clear();
    infoTransportistaController.clear();
    estadoEnvioController.clear();
    instruccionesController.clear();
    costosTarifasController.clear();
    documentacionController.clear();
    notasComentariosController.clear();

    idController.text = rutaenvio['idrutaenvio'];
    origenController.text = rutaenvio['origen'];
    destinoController.text = rutaenvio['destino'];
    detallesEnvioController.text = rutaenvio['detalles_envio'];
    infoTransportistaController.text = rutaenvio['info_transportista'];
    estadoEnvioController.text = rutaenvio['estado_envio'];
    instruccionesController.text = rutaenvio['instrucciones'];
    costosTarifasController.text = rutaenvio['costos_tarifas'];
    documentacionController.text = rutaenvio['documentacion'];
    notasComentariosController.text = rutaenvio['notas_comentarios'];

    errores.clear();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Ruta envio'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    const Icon(Icons.route),
                    const SizedBox(width: 8),
                    const Text(
                      'Información sobre Ruta envios',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildTextField('ID de la Rutaenvio', idController,
                        enabled: false),
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
                    _editarRutaenvio(rutaenvio.id);
                    Navigator.pushNamed(context, '/rutaenvio');
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          enabled: enabled,
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

    if (errores.isEmpty) {
      if (idController.text.isEmpty) {
        _agregarRutaenvio();
      } else {
        _editarRutaenvio(idController.text);
      }
      Navigator.of(context).pop();
    }
  }

  Future<void> _agregarRutaenvio() async {
    CollectionReference rutaenvioCollection =
        _firestore.collection('rutaenvio');

    String id = _firestore.collection('rutaenvio').doc().id;

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

  Future<void> _editarRutaenvio(String id) async {
    CollectionReference rutaenvioCollection =
        _firestore.collection('rutaenvio');

    DocumentReference rutaenvioRef = rutaenvioCollection.doc(id);

    Map<String, dynamic> datosActualizados = {
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
      await rutaenvioRef.update(datosActualizados);
      if (kDebugMode) {
        print('Rutaenvio actualizada correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al actualizar Rutaenvio: $e');
      }
    }
  }

  Future<void> _eliminarRutaenvio(String id) async {
    try {
      await _firestore
          .collection('rutaenvio')
          .where('idrutaenvio', isEqualTo: id)
          .get()
          .then((snapshot) {
        snapshot.docs.first.reference.delete();
      });
      if (kDebugMode) {
        print('Rutaenvio eliminada correctamente');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al eliminar Rutaenvio: $e');
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
