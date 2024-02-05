import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarDepartamento extends StatefulWidget {
  const AgregarDepartamento({Key? key}) : super(key: key);

  @override
  _AgregarDepartamentoState createState() => _AgregarDepartamentoState();
}

class _AgregarDepartamentoState extends State<AgregarDepartamento> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Departamentos'),
        // Agregar un IconButton en el AppBar para la navegación de regreso
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navegar a la pantalla '/departamento' al presionar el botón de regreso
            Navigator.popAndPushNamed(context, '/departamento');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Departamento',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, introduce un nombre.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: ubicacionController,
                decoration: const InputDecoration(
                  labelText: 'Ubicación del Departamento',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, introduce una ubicación.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _agregarDepartamento(context);
                  }
                },
                child: const Text('Agregar Departamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _agregarDepartamento(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('departamento').add({
        'nombre': nombreController.text,
        'ubicacion': ubicacionController.text,
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Departamento agregado exitosamente')),
      );
      Navigator.popAndPushNamed(context, '/departamento');
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error al agregar departamento: $e');
        }
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al agregar departamento')),
      );
    }
  }
}
