import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ordenes App',
      home: Orden(),
    );
  }
}

class Orden extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Órdenes'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('ordenes').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data?.docs;

          if (orders == null || orders.isEmpty) {
            return Center(
              child: Text('No hay órdenes disponibles.'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(order['cliente'] ?? 'Cliente no especificado'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID Orden: ${order['idOrden'] ?? 'N/A'}'),
                    Text('ID Usuario: ${order['idUsuario'] ?? 'N/A'}'),
                    Text('Fecha Creación: ${order['fechaCreacion'] ?? 'N/A'}'),
                    Text('Estado: ${order['estado'] ?? 'N/A'}'),
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
            builder: (BuildContext context) => AgregarOrdenDialog(),
          );

          if (result != null && result is Map<String, dynamic>) {
            // Agregar la nueva orden a Firebase
            await FirebaseFirestore.instance.collection('ordenes').add(result);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class AgregarOrdenDialog extends StatefulWidget {
  @override
  _AgregarOrdenDialogState createState() => _AgregarOrdenDialogState();
}

class _AgregarOrdenDialogState extends State<AgregarOrdenDialog> {
  final TextEditingController idOrdenController = TextEditingController();
  final TextEditingController idUsuarioController = TextEditingController();
  final TextEditingController fechaCreacionController = TextEditingController();
  String estadoValue = 'Pendiente'; // Valor inicial
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Nueva Orden'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: idOrdenController,
            decoration: InputDecoration(labelText: 'ID Orden'),
          ),
          TextField(
            controller: idUsuarioController,
            decoration: InputDecoration(labelText: 'ID Usuario'),
          ),
          TextField(
            controller: fechaCreacionController,
            decoration: InputDecoration(labelText: 'Fecha Creación'),
          ),
          DropdownButtonFormField(
            value: estadoValue,
            items: ['Pendiente', 'En Proceso', 'Completado', 'Cancelado']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                estadoValue = newValue ?? 'Pendiente';
              });
            },
            decoration: InputDecoration(labelText: 'Estado'),
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
              var nuevaOrden = {
                'idOrden': idOrdenController.text,
                'idUsuario': idUsuarioController.text,
                'fechaCreacion': fechaCreacionController.text,
                'estado': estadoValue,
              };

              Navigator.pop(context, nuevaOrden);
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
    if (idOrdenController.text.isEmpty ||
        idUsuarioController.text.isEmpty ||
        fechaCreacionController.text.isEmpty) {
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
