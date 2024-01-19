import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: PedidoVendedor(),
  ));
}

class Pedido {
  final String id;
  String producto;
  int cantidad;

  Pedido({required this.id, required this.producto, required this.cantidad});

  // Método para convertir el objeto Pedido a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'producto': producto,
      'cantidad': cantidad,
    };
  }

  // Método estático para crear un Pedido desde un mapa de Firestore
  static Pedido fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      producto: map['producto'],
      cantidad: map['cantidad'],
    );
  }

  // Método para guardar el pedido en Firestore
  Future<void> guardarEnFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(id)
          .set(toMap());
    } catch (e) {
      print('Error al guardar el pedido en Firestore: $e');
    }
  }
}

class PedidoVendedor extends StatefulWidget {
  @override
  _PedidoVendedorState createState() => _PedidoVendedorState();
}

class _PedidoVendedorState extends State<PedidoVendedor> {
  late TextEditingController _productoController;
  late TextEditingController _cantidadController;
  late Pedido _pedido;

  @override
  void initState() {
    super.initState();
    _productoController = TextEditingController();
    _cantidadController = TextEditingController();
    _pedido = Pedido(id: '1', producto: '', cantidad: 0);
  }

  @override
  void dispose() {
    // Liberar los controladores cuando el widget está siendo eliminado o desmontado
    _productoController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del Pedido'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID del Pedido: ${_pedido.id}'),
            SizedBox(height: 16),
            Text('Producto: ${_pedido.producto}'),
            SizedBox(height: 16),
            Text('Cantidad: ${_pedido.cantidad}'),
            SizedBox(height: 16),
            TextField(
              controller: _productoController,
              decoration: InputDecoration(labelText: 'Nuevo Producto'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Nueva Cantidad'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _actualizarPedido();
              },
              child: Text('Actualizar Pedido'),
            ),
          ],
        ),
      ),
    );
  }

  void _actualizarPedido() {
    setState(() {
      _pedido.producto = _productoController.text;
      _pedido.cantidad = int.tryParse(_cantidadController.text) ?? 0;

      // Puedes guardar el pedido en Firestore aquí si es necesario
      // _pedido.guardarEnFirestore();
    });
  }
}
