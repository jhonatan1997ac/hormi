// ignore_for_file: library_private_types_in_public_api

import 'package:apphormi/pages/inicio/vendedores/vendedor.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<String> _ordenes = [];
  final List<String> _motivos = [
    'Producto defectuoso',
    'Envío incorrecto',
  ];

  @override
  void initState() {
    super.initState();
    _cargarOrdenes();
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const VendedorHome()),
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
                value: null,
                items: _ordenes.map((orden) {
                  return DropdownMenuItem(
                    value: orden,
                    child: Text(
                      orden,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {},
                decoration: InputDecoration(
                  labelText: 'ID de Orden',
                  hintText: 'Seleccione la orden',
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
              TextField(
                controller: _estadoController,
                style: const TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Estado',
                  labelStyle: const TextStyle(
                    color: Colors.black,
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
    );
  }

  void _cargarOrdenes() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ordenes').get();
    List<String> ordenes = [];
    for (var doc in querySnapshot.docs) {
      ordenes.add(doc['idOrden']);
    }
    setState(() {
      _ordenes = ordenes;
    });
  }

  void _guardarReclamacion() async {
    String idOrden = _ordenes.isNotEmpty ? _ordenes.first : '';
    String estado = _estadoController.text;
    if (idOrden.isEmpty || _motivoSeleccionado.isEmpty || estado.isEmpty) {
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
      'idOrden': idOrden,
      'motivo': _motivoSeleccionado,
      'estado': estado,
      'fecha': FieldValue.serverTimestamp(),
    });
    _estadoController.clear();
  }
}
