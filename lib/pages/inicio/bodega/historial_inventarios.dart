// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Historial de Inventario',
      home: HistorialInventario(),
    );
  }
}

class HistorialInventario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Inventario'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('historialinventario')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var historial = snapshot.data?.docs;

          if (historial == null || historial.isEmpty) {
            return Center(
              child: Text('No hay registros en el historial de inventario.'),
            );
          }

          return ListView.builder(
            itemCount: historial.length,
            itemBuilder: (context, index) {
              var registro = historial[index].data() as Map<String, dynamic>;
              return ListTile(
                title:
                    Text(registro['idproducto'] ?? 'Producto no especificado'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID Historial: ${registro['idhistorial'] ?? 'N/A'}'),
                    Text(
                        'Tipo de Movimiento: ${registro['tipomovimiento'] ?? 'N/A'}'),
                    Text('Cantidad: ${registro['cantidad'] ?? 'N/A'}'),
                    Text('Fecha: ${registro['fecha'] ?? 'N/A'}'),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await showDialog(
            context: context,
            builder: (BuildContext context) => const AgregarRegistro(),
          );

          if (result != null && result is Map<String, dynamic>) {
            // Agregar el nuevo registro al historial en Firebase
            await FirebaseFirestore.instance
                .collection('historialinventario')
                .add(result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AgregarRegistro extends StatefulWidget {
  const AgregarRegistro({super.key});

  @override
  _AgregarRegistroState createState() => _AgregarRegistroState();
}

class _AgregarRegistroState extends State<AgregarRegistro> {
  final TextEditingController idProductoController = TextEditingController();
  final TextEditingController tipoMovimientoController =
      TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Nuevo Registro al Historial'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: idProductoController,
            decoration: InputDecoration(labelText: 'ID del Producto'),
          ),
          TextField(
            controller: tipoMovimientoController,
            decoration: InputDecoration(labelText: 'Tipo de Movimiento'),
          ),
          TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Cantidad'),
          ),
          if (errorText.isNotEmpty)
            Text(
              errorText,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_validarDatos()) {
              var nuevoRegistro = {
                'idhistorial': DateTime.now().millisecondsSinceEpoch.toString(),
                'idproducto': idProductoController.text,
                'tipomovimiento': tipoMovimientoController.text,
                'cantidad': int.parse(cantidadController.text),
                'fecha': DateTime.now().toIso8601String(),
              };

              Navigator.pop(context, nuevoRegistro);
            }
          },
          child: Text('Guardar'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancelar'),
        ),
      ],
    );
  }

  bool _validarDatos() {
    if (idProductoController.text.isEmpty ||
        tipoMovimientoController.text.isEmpty ||
        cantidadController.text.isEmpty) {
      setState(() {
        errorText = 'Todos los campos son obligatorios';
      });
      return false;
    } else {
      setState(() {
        errorText = '';
      });
      return true;
    }
  }
}
