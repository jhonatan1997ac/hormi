// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api, non_constant_identifier_names, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Reclamaciones ',
      home: Reclamaciones(),
    );
  }
}

class Reclamaciones extends StatefulWidget {
  const Reclamaciones({Key? key}) : super(key: key);

  @override
  _ReclamacionesState createState() => _ReclamacionesState();
}

class _ReclamacionesState extends State<Reclamaciones> {
  final TextEditingController _estadoController = TextEditingController();
  String _motivoSeleccionado = 'Producto defectuoso';
  String? _productoSeleccionado;
  List<Map<String, dynamic>> _historialventas = [];
  final List<String> _motivos = [
    'Producto defectuoso',
    'Envío incorrecto',
  ];

  @override
  void initState() {
    super.initState();
    _cargarhistorialventas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Formulario de Reclamaciones",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); // Navegar hacia atrás
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
      body: SingleChildScrollView(
        child: Container(
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
                DropdownButtonFormField(
                  value: _motivoSeleccionado,
                  items: _motivos.map((motivo) {
                    return DropdownMenuItem(
                      value: motivo,
                      child: Text(
                        motivo,
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _motivoSeleccionado = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Motivo',
                    hintText: 'Seleccione el motivo',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                DropdownButtonFormField(
                  value: _productoSeleccionado,
                  items: _historialventas.isNotEmpty
                      ? _historialventas.map((orden) {
                          return DropdownMenuItem(
                            value: orden['producto_id'],
                            child: Text(
                              orden['producto_id'],
                              style: const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList()
                      : [
                          const DropdownMenuItem(
                            value: null,
                            child: Text(
                              'No hay productos disponibles',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                  onChanged: (value) {
                    setState(() {
                      _productoSeleccionado = value as String?;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Id producto',
                    hintText: 'Seleccione el producto',
                    labelStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                const SizedBox(height: 40.0),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _guardarReclamacion();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        'Notificar Reclamación',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _cargarhistorialventas() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('historialventas').get();
    List<Map<String, dynamic>> historialventas = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      // Verificar si el documento tiene datos y si los datos son del tipo esperado
      if (data != null && data is Map<String, dynamic>) {
        var producto_id = data["producto_id"];
        if (producto_id != null) {
          historialventas.add({
            'producto_id': producto_id,
          });
        }
      }
    }
    setState(() {
      _historialventas = historialventas;
    });
  }

  void _guardarReclamacion() async {
    Map<String, dynamic>? firstItem =
        _historialventas.isNotEmpty ? _historialventas.first : null;
    String producto_id = firstItem != null ? firstItem['producto_id'] : '';
    String estado = _estadoController.text;
    if (producto_id.isEmpty || _motivoSeleccionado.isEmpty || estado.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text(
                'Por favor, complete todos los campos y seleccione un motivo y una orden.'),
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
      return;
    }

    await FirebaseFirestore.instance.collection('reclamaciones').add({
      'producto_id': producto_id,
      'motivo': _motivoSeleccionado,
      'estado': estado,
      'fecha': FieldValue.serverTimestamp(),
    });
    _estadoController.clear();
  }
}
