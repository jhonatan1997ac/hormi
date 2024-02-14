import 'package:apphormi/pages/inicio/administrador/administrador.dart';
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
      title: 'Pedidos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            textStyle: TextStyle(fontSize: 18),
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const Detallepedidoadmin(),
    );
  }
}

class Detallepedidoadmin extends StatefulWidget {
  const Detallepedidoadmin({Key? key});

  @override
  _DetallepedidoadminState createState() => _DetallepedidoadminState();
}

class _DetallepedidoadminState extends State<Detallepedidoadmin> {
  final TextEditingController idDetalleController = TextEditingController();
  final TextEditingController idOrdenController = TextEditingController();
  final TextEditingController idProductoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detalle de Órdenes",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Administrador()),
            );
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 55, 111, 139),
              Color.fromARGB(255, 165, 160, 160),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('detalleorden')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
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

                    return ListView.builder(
                      itemCount: detalleOrdenes.length,
                      itemBuilder: (context, index) {
                        var detalleOrden = detalleOrdenes[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              'ID Detalle: ${detalleOrden.idDetalle}',
                              style: TextStyle(color: Colors.black87),
                            ),
                            subtitle: Text(
                              'ID Orden: ${detalleOrden.idOrden}\nCantidad: ${_getCantidadText(detalleOrden.cantidad)}',
                              style: TextStyle(color: Colors.black87),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _eliminarDetalle(detalleOrden.idDetalle);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => _agregarDetalle(context),
                child: Text('Agregar Detalle'),
              ),
            ],
          ),
        ),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
            ElevatedButton(
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

  void _eliminarDetalle(String idDetalle) {
    FirebaseFirestore.instance
        .collection('detalleorden')
        .doc(idDetalle)
        .delete();
  }
}
