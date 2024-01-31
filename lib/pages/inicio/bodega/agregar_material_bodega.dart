// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarMaterial(
      String nombre, String descripcion, String cantidad) async {
    try {
      var existingMaterial = await _firestore
          .collection('disponibilidadmaterial')
          .where('nombre', isEqualTo: nombre)
          .get();

      if (existingMaterial.docs.isNotEmpty) {
        print('Material existente. Puedes implementar lógica específica.');
      } else {
        if (_esValido(nombre, descripcion, cantidad)) {
          await _firestore.collection('disponibilidadmaterial').add({
            'nombre': nombre,
            'descripcion': descripcion,
            'cantidad': int.parse(cantidad), // Convierte a entero
          });

          print('Material agregado correctamente a la base de datos.');
        } else {
          print('Datos no válidos. No se ha agregado el material.');
        }
      }
    } catch (e) {
      print('Error al agregar el material: $e');
    }
  }

  bool _esValido(String nombre, String descripcion, String cantidad) {
    return cantidad.isNotEmpty && nombre.isNotEmpty && descripcion.isNotEmpty;
  }
}

class AgregarMaterial extends StatefulWidget {
  const AgregarMaterial({Key? key}) : super(key: key);

  @override
  _AgregarMaterialState createState() => _AgregarMaterialState();
}

class _AgregarMaterialState extends State<AgregarMaterial> {
  String _selectedMaterial = 'Arena';
  String _selectedDescripcion = 'Volqueta';
  String _selectedCantidad = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Material'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Escoja el material:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedMaterial,
                items: [
                  'Arena',
                  'Piedra',
                  'Ripio',
                  'Piedra triturada',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedMaterial = newValue ?? '';
                  });
                },
              ),
              SizedBox(height: 16.0),
              const Text(
                'Escoja el modo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedDescripcion,
                items: [
                  'Volqueta',
                  'Mamut',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDescripcion = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Escoja la cantidad:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: _selectedCantidad,
                items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCantidad = newValue ?? '';
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _agregarMaterial();
                  },
                  child: const Text('Agregar Material'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _agregarMaterial() async {
    final nombre = _selectedMaterial;
    final descripcion = _selectedDescripcion;
    final cantidad = _selectedCantidad;

    final materialService = MaterialService();
    await materialService.agregarMaterial(nombre, descripcion, cantidad);

    Navigator.pushNamed(context, '/disponibilidadmaterial');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Aplicación',
      home: AgregarMaterial(),
    );
  }
}

void main() {
  runApp(MyApp());
}
