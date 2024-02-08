import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Reclamaciones App',
      home: Reclamaciones(),
    );
  }
}

class Reclamaciones extends StatefulWidget {
  const Reclamaciones({super.key});

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
        title: const Text('Formulario de Reclamaciones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: _motivoSeleccionado,
              items: _motivos.map((motivo) {
                return DropdownMenuItem(
                  value: motivo,
                  child: Text(motivo),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _motivoSeleccionado = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Motivo',
                hintText: 'Seleccione el motivo',
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField(
              value: null,
              items: _ordenes.map((orden) {
                return DropdownMenuItem(
                  value: orden,
                  child: Text(orden),
                );
              }).toList(),
              onChanged: (value) {},
              decoration: const InputDecoration(
                labelText: 'ID de Orden',
                hintText: 'Seleccione la orden',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _estadoController,
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _guardarReclamacion();
              },
              child: const Text('Notificar Reclamación'),
            ),
          ],
        ),
      ),
    );
  }

  void _cargarOrdenes() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('ordenes').get();
    List<String> ordenes = [];
    querySnapshot.docs.forEach((doc) {
      ordenes.add(doc['idOrden']);
    });
    setState(() {
      _ordenes = ordenes;
    });
  }

  void _guardarReclamacion() async {
    String idOrden = _ordenes.isNotEmpty
        ? _ordenes.first
        : ''; // Obtener la primera orden si está disponible
    String estado = _estadoController.text;

    // Validar que los campos no estén vacíos y que el motivo sea seleccionado
    if (idOrden.isEmpty || _motivoSeleccionado.isEmpty || estado.isEmpty) {
      // Mostrar un mensaje de error o realizar otra acción de manejo de errores
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

    // Guardar en Firebase
    await FirebaseFirestore.instance.collection('reclamaciones').add({
      'idOrden': idOrden,
      'motivo': _motivoSeleccionado,
      'estado': estado,
      'fecha': FieldValue.serverTimestamp(),
    });

    // Limpiar los controladores después de enviar la reclamación
    _estadoController.clear();
  }
}
