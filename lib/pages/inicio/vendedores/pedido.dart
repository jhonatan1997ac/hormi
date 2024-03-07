// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unused_element, use_build_context_synchronously, prefer_const_declaration
import 'package:apphormi/pages/inicio/vendedores/vista_pedido.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IniciarPedido extends StatefulWidget {
  @override
  _IniciarPedidoState createState() => _IniciarPedidoState();
}

class _IniciarPedidoState extends State<IniciarPedido> {
  final TextEditingController _cantidadController = TextEditingController();
  String? _selectedProduct = 'Seleccione un Producto';
  String _calidad = 'Calidad adoquin resistencia 300';
  DateTime _selectedDate = DateTime.now();
  bool _isValidProduct = false;
  bool _isValidDate = false;
  bool _isValidQuality = false;
  bool _isValidQuantity = false;
  int _lastId = 0;
  final Map<String, Map<String, dynamic>> _productosInfo = {
    'Adoquin clasico vehicular sin color': {'cantidad': 3034, 'precio': 0.20},
    'Adoquin clasico vehicular con color': {'cantidad': 3034, 'precio': 0.25},
    'Adoquin jaboncillo vehicular sin color': {
      'cantidad': 7585,
      'precio': 0.08
    },
    'Adoquin jaboncillo vehicular con color': {
      'cantidad': 7585,
      'precio': 0.10
    },
    'Adoquin paleta vehicular sin color': {'cantidad': 1050, 'precio': 0.11},
    'Adoquin paleta vehicular con color': {'cantidad': 1050, 'precio': 0.13},
    'Bloque de 10cm estructural': {'cantidad': 1050, 'precio': 0.18},
    'Bloque de 15cm estructural': {'cantidad': 800, 'precio': 0.20},
    'Postes de alambrado 1.60m': {'cantidad': 504, 'precio': 4.36},
    'Postes de alambrado 2m': {'cantidad': 396, 'precio': 5},
    'Bloque de anclaje': {'cantidad': 468, 'precio': 1.88},
    'Tapas para canaleta': {'cantidad': 234, 'precio': 40},
  };

  void _validateProduct() {
    setState(() {
      _isValidProduct = _selectedProduct != 'Seleccione un Producto';
    });
  }

  void _validateDate() {
    setState(() {
      _isValidDate = true;
    });
  }

  void _validateQuality() {
    setState(() {
      _isValidQuality = true;
    });
  }

  void _validateQuantity(String value) {
    setState(() {
      _isValidQuantity = value.isNotEmpty;
    });
  }

  void _guardarPedido() async {
    int cantidad = int.tryParse(_cantidadController.text) ?? 0;

    if (_isValidProduct &&
        _isValidDate &&
        _isValidQuality &&
        _isValidQuantity) {
      try {
        double precio = _productosInfo[_selectedProduct]!['precio'];
        int diasNecesarios = _calcularDiasNecesarios(cantidad);
        _lastId++;

        await FirebaseFirestore.instance.collection('pedidorealizado').add({
          'idpedido': _lastId,
          'nombre': _selectedProduct!,
          'fecha': _selectedDate,
          'calidad': _calidad,
          'precio': precio,
          'cantidad': cantidad,
          'diasNecesarios': diasNecesarios,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pedido realizado con éxito',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        _cantidadController.clear();
        setState(() {
          _selectedProduct = 'Seleccione un Producto';
          _calidad = 'Calidad adoquin resistencia 300';
          _selectedDate = DateTime.now();
          _isValidProduct = false;
          _isValidDate = false;
          _isValidQuality = false;
          _isValidQuantity = false;
        });

        // Redireccionar a la vista de pedidos
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VistaPedidos()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al guardar el pedido: $error',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa todos los campos correctamente',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _calcularDiasNecesarios(int cantidad) {
    String selectedProductName = _selectedProduct ?? '';
    int cantidadMinima = _productosInfo[selectedProductName]!['cantidad'] ?? 0;
    int diasNecesarios = cantidad ~/ cantidadMinima;
    if (cantidad % cantidadMinima != 0) {
      diasNecesarios++;
    }

    return diasNecesarios;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().toUtc().subtract(const Duration(hours: 5)),
      lastDate: DateTime(2101).toUtc().subtract(const Duration(hours: 5)),
    );

    if (picked != null && picked != _selectedDate) {
      // Convertir la fecha seleccionada a la zona horaria local
      final pickedLocalTime = picked
          .toUtc()
          .add(const Duration(hours: 5)); // Ajuste de la zona horaria

      setState(() {
        _selectedDate = pickedLocalTime;
        _isValidDate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Iniciar Pedido',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona un Producto:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: _selectedProduct,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedProduct = newValue;
                  _validateProduct();
                });
              },
              items: [
                ..._productosInfo.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }),
                const DropdownMenuItem<String>(
                  value: 'Seleccione un Producto',
                  child: Text('Seleccione un Producto'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            if (_isValidProduct)
              Row(
                children: [
                  const Text(
                    'Fecha de Creación:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      DateFormat('dd/MM/yyyy').format(_selectedDate),
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            if (_isValidDate)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calidad:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _calidad,
                    onChanged: (String? newValue) {
                      setState(() {
                        _calidad = newValue!;
                        _validateQuality();
                      });
                    },
                    items: <String>[
                      'Calidad adoquin resistencia 300',
                      'Calidad adoquin resistencia 350',
                      'Calidad adoquin resistencia 400',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            if (_isValidQuality)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _cantidadController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cantidad',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _validateQuantity,
                  ),
                  const SizedBox(height: 16.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isValidQuantity ? _guardarPedido : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Guardar Pedido',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
