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

class OrdenModel {
  String id;
  String nombre;

  OrdenModel({
    required this.id,
    required this.nombre,
  });

  factory OrdenModel.fromMap(Map<String, dynamic> map) {
    return OrdenModel(
      id: map['id'].toString(),
      nombre: map['nombre'].toString(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
  final TextEditingController idProductoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();

  late Stream<String?> idOrdenSeleccionado;
  late List<OrdenModel> ordenes;

  @override
  void initState() {
    super.initState();
    idOrdenSeleccionado = Stream.value(null);
    _cargarOrdenes();
  }

  Future<void> _cargarOrdenes() async {
    FirebaseFirestore.instance
        .collection('ordenes')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      setState(() {
        ordenes = querySnapshot.docs
            .map(
              (doc) => OrdenModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Órdenes'),
      ),
      body: StreamBuilder(
        stream: idOrdenSeleccionado,
        builder: (context, AsyncSnapshot<String?> idOrdenSnapshot) {
          if (idOrdenSnapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('detalleorden')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
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
                    onPressed: () =>
                        _agregarDetalle(context, idOrdenSnapshot.data),
                    child: const Text('Agregar Detalle'),
                  ),
                ],
              );
            },
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

  Future<void> _agregarDetalle(BuildContext context, String? idOrden) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Detalle'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: idOrden,
                  onChanged: (String? newValue) {
                    setState(() {
                      idOrdenSeleccionado = Stream.value(newValue);
                    });
                  },
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Seleccionar Orden'),
                    ),
                    ...ordenes.map((OrdenModel orden) {
                      return DropdownMenuItem<String>(
                        value: orden.id,
                        child: Text('${orden.nombre}'),
                      );
                    }).toList(),
                  ],
                  decoration: const InputDecoration(labelText: 'ID Orden'),
                ),
                TextFormField(
                  controller: idProductoController,
                  decoration: const InputDecoration(labelText: 'ID Producto'),
                ),
                TextFormField(
                  controller: cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                _enviarDatosAFirebase(idOrdenSeleccionado); // Pasar el Stream
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _enviarDatosAFirebase(Stream<String?> idOrdenStream) {
    idOrdenStream.listen((String? idOrden) {
      if (idOrden != null &&
          idProductoController.text.isNotEmpty &&
          cantidadController.text.isNotEmpty) {
        DetalleOrdenesModel nuevoDetalle = DetalleOrdenesModel(
          idDetalle: idDetalleController.text,
          idOrden: idOrden,
          idProducto: idProductoController.text,
          cantidad: int.parse(cantidadController.text),
        );

        FirebaseFirestore.instance.collection('detalleorden').add({
          'idDetalle': nuevoDetalle.idDetalle,
          'idOrden': idOrden,
          'idProducto': nuevoDetalle.idProducto,
          'cantidad': nuevoDetalle.cantidad,
        });

        idDetalleController.clear();
        idProductoController.clear();
        cantidadController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, completa todos los campos.'),
          ),
        );
      }
    });
  }
}
