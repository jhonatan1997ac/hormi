import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productos',
      home: DisponibilidadProducto(),
    );
  }
}

class DisponibilidadProducto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Datos ingresados'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('disponibilidadproducto')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          var productos = snapshot.data!.docs;
          List<Widget> productosWidget = [];
          for (var producto in productos) {
            var productoData = producto.data() as Map<String, dynamic>;
            productosWidget.add(
              ListTile(
                title: Text(productoData['nombre']),
                subtitle: Text(
                    'Precio: ${productoData['precio']}, Cantidad: ${productoData['cantidad']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Disponible: ${productoData['disponible'] == 1 ? 'Sí' : 'No'}',
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.pushNamed(context, '/editarproducto');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Navigator.pushNamed(context, '/editarproducto');
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView(
            children: productosWidget,
          );
        },
      ),
    );
  }
}
