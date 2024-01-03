import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class SoporteProvider {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> preguntasFrecuentes = [
    '¿Cómo restablecer mi contraseña?',
    '¿Cómo actualizar la aplicación?',
    '¿Cómo puedo contactar al soporte técnico?',
  ];

  List<String> historialConsultas = [];

  Future<void> agregarConsulta(String consulta) async {
    historialConsultas.add(consulta);
    await firestore.collection('consultas').add({
      'consulta': consulta,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Soporte y Ayuda',
      home: SoporteScreen(),
    );
  }
}

class SoporteScreen extends StatefulWidget {
  const SoporteScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SoporteScreenState createState() => _SoporteScreenState();
}

class _SoporteScreenState extends State<SoporteScreen> {
  final SoporteProvider soporteProvider = SoporteProvider();
  String consulta = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte y Ayuda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Preguntas Frecuentes:'),
            PreguntasFrecuentesList(
                preguntas: soporteProvider.preguntasFrecuentes),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _mostrarFormularioContacto(context);
              },
              child: const Text('Contactar Soporte'),
            ),
            const SizedBox(height: 20.0),
            const Text('Historial de Consultas:'),
            HistorialConsultasList(
                consultas: soporteProvider.historialConsultas),
          ],
        ),
      ),
    );
  }

  void _mostrarFormularioContacto(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Formulario de Contacto'),
          content: TextField(
            maxLines: 3,
            onChanged: (value) {
              consulta = value.trim();
            },
            decoration: const InputDecoration(
              labelText: 'Escribe tu consulta...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await soporteProvider.agregarConsulta(consulta);
                setState(() {
                  soporteProvider.agregarConsulta(consulta);
                });
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}

class PreguntasFrecuentesList extends StatelessWidget {
  final List<String> preguntas;

  const PreguntasFrecuentesList({super.key, required this.preguntas});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: preguntas.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(preguntas[index]),
        );
      },
    );
  }
}

class HistorialConsultasList extends StatelessWidget {
  final List<String> consultas;

  const HistorialConsultasList({super.key, required this.consultas});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: consultas.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(consultas[index]),
        );
      },
    );
  }
}
