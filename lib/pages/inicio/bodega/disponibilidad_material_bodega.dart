import 'package:cloud_firestore/cloud_firestore.dart';
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
        imagenURL: material.imagenURL,
      );
      bool confirmacion =
          (await _mostrarConfirmacion(context, materialEditado)) as bool;
      if (confirmacion) {
        await materialesCollection.doc(material.nombre).update({
          'cantidad': materialEditado.cantidad,
          'descripcion': materialEditado.descripcion,
        });

        print('Material actualizado: $materialEditado');
      }
    } catch (e) {
      print('Error al editar el material: $e');
    }
  }

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
                        title: Row(
                          children: [
                            if (material.imagenURL != null)
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Image.network(
                                  material.imagenURL!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(material.nombre),
                                  Text('Cantidad: ${material.cantidad}'),
                                  Text('Descripción: ${material.descripcion}'),
                                ],
                              ),
                            ),
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

  Future<bool> _mostrarConfirmacion(
      BuildContext context, MaterialAgregado materialEditado) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmar Edición'),
              content:
                  const Text('¿Está seguro de que desea editar este material?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class MaterialAgregado {
  final String nombre;
  final int cantidad;
  final String descripcion;
  final String? imagenURL;

  MaterialAgregado({
    required this.nombre,
    required this.cantidad,
    required this.descripcion,
    this.imagenURL,
  });

  MaterialAgregado.fromSnapshot(DocumentSnapshot snapshot)
      : nombre = snapshot.id,
        cantidad = snapshot['cantidad'] ?? 0,
        descripcion = snapshot['descripcion'] ?? '',
        imagenURL = snapshot['imagenURL'] ?? '';

  Map<String, dynamic> toMap() {
    return {
      'cantidad': cantidad,
      'descripcion': descripcion,
      'imagenURL': imagenURL,
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
  late TextEditingController nombreController;
  late TextEditingController cantidadController;

  @override
  void initState() {
    super.initState();
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
            ElevatedButton(
              onPressed: () async {
                final materialActualizado = MaterialAgregado(
                  nombre: nombreController.text,
                  cantidad: int.parse(cantidadController.text),
                  descripcion: widget.material.descripcion,
                  imagenURL: widget.material.imagenURL,
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
