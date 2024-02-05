import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class DetalleOrdenesModel {
  String idDetalle;
  String idOrden;
  String idProducto;
  dynamic cantidad;

  DetalleOrdenesModel({
    required this.idDetalle,
    required this.idOrden,
    required this.idProducto,
    required this.cantidad,
  });

  factory DetalleOrdenesModel.fromMap(Map<String, dynamic> map) {
    return DetalleOrdenesModel(
      idDetalle: map['idDetalle'].toString(),
      idOrden: map['idOrden'].toString(),
      idProducto: map['idProducto'].toString(),
      cantidad: map['cantidad'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detalle de Órdenes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DetalleOrdenes(),
    );
  }
}

class DetalleOrdenes extends StatefulWidget {
  const DetalleOrdenes({Key? key});

  @override
  _DetalleOrdenesState createState() => _DetalleOrdenesState();
}

class _DetalleOrdenesState extends State<DetalleOrdenes> {
  final TextEditingController idDetalleController = TextEditingController();
  final TextEditingController idOrdenController = TextEditingController();
  final TextEditingController idProductoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Órdenes'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('detalleorden').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          var detalleOrdenes = snapshot.data!.docs
              .map(
                (doc) => DetalleOrdenesModel(
                  idDetalle: doc['idDetalle'].toString(),
                  idOrden: doc['idOrden'].toString(),
                  idProducto: doc['idProducto'].toString(),
                  cantidad: doc['cantidad'],
                ),
              )
              .toList();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: detalleOrdenes.length,
                  itemBuilder: (context, index) {
                    var detalleOrden = detalleOrdenes[index];
                    return ListTile(
                      title: Text('ID Detalle: ${detalleOrden.idDetalle}'),
                      subtitle: Text(
                        'ID Orden: ${detalleOrden.idOrden}\nCantidad: ${_getCantidadText(detalleOrden.cantidad)}',
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => _agregarDetalle(context),
                child: Text('Agregar Detalle'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getCantidadText(dynamic cantidad) {
    if (cantidad is int) {
      return cantidad.toString();
    }
    return cantidad.toString();
  }

  Future<void> _agregarDetalle(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Detalle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: idDetalleController,
                  decoration: InputDecoration(labelText: 'ID Detalle'),
                ),
                TextFormField(
                  controller: idOrdenController,
                  decoration: InputDecoration(labelText: 'ID Orden'),
                ),
                TextFormField(
                  controller: idProductoController,
                  decoration: InputDecoration(labelText: 'ID Producto'),
                ),
                TextFormField(
                  controller: cantidadController,
                  decoration: InputDecoration(labelText: 'Cantidad'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _enviarDatosAFirebase();
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _enviarDatosAFirebase() {
    if (idDetalleController.text.isNotEmpty &&
        idOrdenController.text.isNotEmpty &&
        idProductoController.text.isNotEmpty &&
        cantidadController.text.isNotEmpty) {
      DetalleOrdenesModel nuevoDetalle = DetalleOrdenesModel(
        idDetalle: idDetalleController.text,
        idOrden: idOrdenController.text,
        idProducto: idProductoController.text,
        cantidad: int.parse(cantidadController.text),
      );

      FirebaseFirestore.instance.collection('detalleorden').add({
        'idDetalle': nuevoDetalle.idDetalle,
        'idOrden': nuevoDetalle.idOrden,
        'idProducto': nuevoDetalle.idProducto,
        'cantidad': nuevoDetalle.cantidad,
      });

      idDetalleController.clear();
      idOrdenController.clear();
      idProductoController.clear();
      cantidadController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos.'),
        ),
      );
    }
  }
}
