import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disponibilidad de material',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DisponibilidadMaterial(),
    );
  }
}

class DisponibilidadMaterial extends StatefulWidget {
  const DisponibilidadMaterial({Key? key}) : super(key: key);

  @override
  _DisponibilidadMaterialState createState() => _DisponibilidadMaterialState();
}

class _DisponibilidadMaterialState extends State<DisponibilidadMaterial> {
  late CollectionReference materialesCollection;

  @override
  void initState() {
    super.initState();
    materialesCollection =
        FirebaseFirestore.instance.collection('disponibilidadmaterial');
  }

  Future<void> editarMaterial(MaterialAgregado material) async {
    try {
      MaterialAgregado materialEditado = MaterialAgregado(
        nombre: material.nombre,
        cantidad: material.cantidad,
        descripcion: material.descripcion,
      );
      bool confirmacion =
          (await _mostrarConfirmacion(context, materialEditado)) as bool;
      if (confirmacion) {
        await materialesCollection.doc(material.nombre).update({
          'cantidad': materialEditado.cantidad,
          'descripcion': materialEditado.descripcion,
        });

        if (kDebugMode) {
          print('Material actualizado: $materialEditado');
        }
      }
    } catch (e) {
      print('Error al editar el material: $e');
    }
  }

  // Resto del código sin cambios...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disponibilidad de material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: materialesCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final material = MaterialAgregado.fromSnapshot(
                          snapshot.data!.docs[index]);
                      return ListTile(
                        title: Text(material.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cantidad: ${material.cantidad}'),
                            Text('Descripción: ${material.descripcion}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditarMaterialScreen(
                                      material: material,
                                    ),
                                  ),
                                ).then((materialActualizado) async {
                                  if (materialActualizado != null) {
                                    await editarMaterial(materialActualizado);
                                    print(
                                        'Material actualizado: $materialActualizado');
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                eliminarMaterial(material);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void eliminarMaterial(MaterialAgregado material) {}
}

class _mostrarConfirmacion {
  _mostrarConfirmacion(BuildContext context, MaterialAgregado materialEditado);
}

class MaterialAgregado {
  final String nombre;
  final int cantidad;
  final String descripcion;

  MaterialAgregado({
    required this.nombre,
    required this.cantidad,
    required this.descripcion,
  });

  MaterialAgregado.fromSnapshot(DocumentSnapshot snapshot)
      : nombre = snapshot.id,
        cantidad = snapshot['cantidad'] ?? 0,
        descripcion = snapshot['descripcion'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'cantidad': cantidad,
      'descripcion': descripcion,
    };
  }
}

class EditarMaterialScreen extends StatefulWidget {
  final MaterialAgregado material;

  EditarMaterialScreen({required this.material});

  @override
  _EditarMaterialScreenState createState() => _EditarMaterialScreenState();
}

class _EditarMaterialScreenState extends State<EditarMaterialScreen> {
  late String selectedDescripcion;
  late TextEditingController nombreController;
  late TextEditingController cantidadController;
  late List<String> opcionesDescripcion;

  @override
  void initState() {
    super.initState();
    selectedDescripcion = widget.material.descripcion;
    opcionesDescripcion = ['Volqueta', 'Mamut'];
    nombreController = TextEditingController(text: widget.material.nombre);
    cantidadController =
        TextEditingController(text: widget.material.cantidad.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nombre:'),
            const SizedBox(height: 16.0),
            TextField(
              controller: nombreController,
              decoration:
                  const InputDecoration(labelText: 'Nombre del Material'),
            ),
            const SizedBox(height: 16.0),
            const Text('Cantidad:'),
            const SizedBox(height: 16.0),
            TextField(
              controller: cantidadController,
              decoration:
                  const InputDecoration(labelText: 'Cantidad del Material'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            const Text('Descripción:'),
            const SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedDescripcion,
              onChanged: (String? newValue) {
                setState(() {
                  selectedDescripcion = newValue!;
                });
              },
              items: opcionesDescripcion.map((String opcion) {
                return DropdownMenuItem<String>(
                  value: opcion,
                  child: Text(opcion),
                );
              }).toList(),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final materialActualizado = MaterialAgregado(
                  nombre: nombreController.text,
                  cantidad: int.parse(cantidadController.text),
                  descripcion: selectedDescripcion,
                );

                Navigator.pop(context, materialActualizado);
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
