import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class Transporte extends StatefulWidget {
  const Transporte({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TransporteState createState() => _TransporteState();
}

class _TransporteState extends State<Transporte> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController idController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController contactoController = TextEditingController();
  TextEditingController extra1Controller = TextEditingController();
  TextEditingController extra2Controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transporte App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Datos de Transportes'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Column(
          children: [
            const Icon(Icons.directions_bus),
            const SizedBox(width: 20),
            const Text(
              'Información sobre Transportes',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildTransportesTable(),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _mostrarDialogoAgregarTransporte(context);
                },
                child: const Text('Agregar Transporte'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportesTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('transporte')
          .orderBy('idtransporte')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        var transportes = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Contacto')),
              DataColumn(label: Text('Extra 1')),
              DataColumn(label: Text('Extra 2')),
            ],
            rows: transportes.map((transporte) {
              var id = transporte['idtransporte'];
              var nombre = transporte['nombre'];
              var contacto = transporte['contacto'];
              var extra1 = transporte['campo_extra_1'];
              var extra2 = transporte['campo_extra_2'];

              return DataRow(cells: [
                DataCell(Text(id)),
                DataCell(Text(nombre)),
                DataCell(Text(contacto)),
                DataCell(Text(extra1)),
                DataCell(Text(extra2)),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _mostrarDialogoAgregarTransporte(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Transporte'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.directions_bus), // Icono de transporte
                const SizedBox(width: 8),
                const Text(
                  'Información sobre Transportes',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  controller: idController,
                  decoration:
                      const InputDecoration(labelText: 'ID del Transporte'),
                ),
                TextField(
                  controller: nombreController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre del Transporte'),
                ),
                TextField(
                  controller: contactoController,
                  decoration: const InputDecoration(
                      labelText: 'Contacto del Transporte'),
                ),
                TextField(
                  controller: extra1Controller,
                  decoration: const InputDecoration(labelText: 'Campo Extra 1'),
                ),
                TextField(
                  controller: extra2Controller,
                  decoration: const InputDecoration(labelText: 'Campo Extra 2'),
                ),
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
                agregarTransporte();
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> agregarTransporte() async {
    CollectionReference transporteCollection =
        _firestore.collection('transporte');

    Map<String, dynamic> nuevoTransporte = {
      'idtransporte': idController.text,
      'nombre': nombreController.text,
      'contacto': contactoController.text,
      'tipotransporte': extra1Controller.text,
      'campo_extra_2': extra2Controller.text,
    };

    try {
      await transporteCollection.add(nuevoTransporte);
      if (kDebugMode) {
        print('Transporte agregado correctamente');
      }
      // Puedes limpiar los controladores después de agregar el transporte si es necesario
      idController.clear();
      nombreController.clear();
      contactoController.clear();
      extra1Controller.clear();
      extra2Controller.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar transporte: $e');
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Transporte();
  }
}
