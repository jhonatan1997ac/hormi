import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> agregarProducto(Producto nuevoProducto) async {
    try {
      await _firestore.collection('disponibilidadproducto').add({
        'nombre': nuevoProducto.nombre,
        'precio': nuevoProducto.precio,
        'cantidad': nuevoProducto.cantidad,
        'disponible': nuevoProducto.disponible,
      });
      if (kDebugMode) {
        print('Producto agregado correctamente a la base de datos.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al agregar el producto: $e');
      }
    }
  }
}

class Producto {
  String nombre;
  double precio;
  int cantidad;
  int disponible;

  Producto({
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.disponible,
  });

  // Método para convertir el número de disponibilidad a un valor booleano
  bool get estaDisponible => disponible == 1;
}

class AgregarProducto extends StatefulWidget {
  const AgregarProducto({super.key});

  @override
  _AgregarProductoState createState() => _AgregarProductoState();
}

class _AgregarProductoState extends State<AgregarProducto> {
  final _precioController = TextEditingController();
  final _cantidadController = TextEditingController();
  bool _disponible = true;
  String _selectedProducto =
      'Adoquin clasico peatonal sin color'; // Valor inicial del menú desplegable
  final List<String> _productos = [
    'Adoquin clasico peatonal sin color',
    'Adoquin clasico peatonal con color',
    'Adoquin clasico vehicular sin color',
    'Adoquin clasico vehicular con color',
    'Adoquin jaboncillo peatonal sin color',
    'Adoquin jaboncillo peatonal con color',
    'Adoquin jaboncillo vehicular sin color',
    'Adoquin jaboncillo vehicular con color',
    'Adoquin paleta peatonal sin color',
    'Adoquin paleta peatonal con color',
    'Adoquin paleta vehicular sin color',
    'Adoquin paleta vehicular con color',
    'Bloque de 10cm alivianado',
    'Bloque de 10cm estructural',
    'Bloque de 15cm alivianado',
    'Bloque de 15cm estructural',
    'Bloque de 20cm alivianado',
    'Bloque de 20cm estructural',
    'Postes de alambrado 1.60m',
    'Postes de alambrado 2m',
    'Bloque de anclaje',
    'Tapas para canaleta',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Nombre:'),
                SizedBox(width: 16.0),
                DropdownButton<String>(
                  value: _selectedProducto,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedProducto = newValue!;
                    });
                  },
                  items:
                      _productos.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(labelText: 'Precio'),
              controller: _precioController,
              keyboardType: TextInputType.number,
            ),
            if (int.tryParse(_precioController.text) != null &&
                int.parse(_precioController.text) > 0)
              const Text(
                'La precio debe ser mayor a 0',
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              decoration: const InputDecoration(labelText: 'Cantidad'),
              controller: _cantidadController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(width: 20.0),
            if (int.tryParse(_cantidadController.text) != null &&
                int.parse(_cantidadController.text) < 1)
              const Text(
                'La cantidad debe ser mayor o igual a 1',
                style: TextStyle(color: Colors.red),
              ),
            Row(
              children: [
                const Text('Disponible:'),
                Switch(
                  value: _disponible,
                  onChanged: (value) {
                    setState(() {
                      _disponible = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (int.tryParse(_cantidadController.text) != null &&
                    int.parse(_cantidadController.text) >= 1) {
                  _agregarProducto();
                  Navigator.pushNamed(context, '/disponibilidadproducto');
                }
              },
              child: const Text('Agregar Producto'),
            ),
          ],
        ),
      ),
    );
  }

  void _agregarProducto() {
    final nombre = _selectedProducto;
    final precio = double.parse(_precioController.text);
    final cantidad = int.parse(_cantidadController.text);

    final nuevoProducto = Producto(
      nombre: nombre,
      precio: precio,
      cantidad: cantidad,
      disponible: _disponible ? 1 : 0,
    );

    final productoService = ProductoService();
    productoService.agregarProducto(nuevoProducto);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Mi Aplicación',
      home: AgregarProducto(),
    );
  }
}

void main() {
  runApp(MyApp());
}
