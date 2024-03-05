// ignore_for_file: unused_local_variable

import 'package:apphormi/pages/inicio/vendedores/venta_vendedor.dart';
import 'package:flutter/material.dart';

class CarritoDeCompras extends StatelessWidget {
  final List<Producto> carrito;

  const CarritoDeCompras({Key? key, required this.carrito}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.green,
      ),
      body: carrito.isEmpty
          ? const Center(
              child: Text(
                'El carrito está vacío',
                style: TextStyle(fontSize: 20),
              ),
            )
          : ListView.builder(
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final producto = carrito[index];
                return ListTile(
                  title: Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    'Cantidad: ${producto.cantidad}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal: \$${calcularSubtotal(carrito).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: () {
                    if (carrito.isNotEmpty) {
                      mostrarDialogoTipoPago(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El carrito está vacío'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 27, 99, 29),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Proceder al Pago',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double calcularSubtotal(List<Producto> productos) {
    return productos.fold(0.0, (subtotal, producto) {
      return subtotal + producto.precio * producto.cantidad;
    });
  }

  void mostrarDialogoTipoPago(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tipo de Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opciones de pago
              ListTile(
                title: const Text('Efectivo'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Lógica para el pago en efectivo
                  mostrarDialogoRegistroPago(context);
                },
              ),
              ListTile(
                title: const Text('Tarjeta de Crédito'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Lógica para el pago con tarjeta de crédito
                  // Puedes implementar una función similar a mostrarDialogoRegistroPago() para la entrada de detalles de tarjeta
                },
              ),
              ListTile(
                title: const Text('Transferencia Bancaria'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Lógica para el pago con transferencia bancaria
                  // Puedes implementar una función similar a mostrarDialogoRegistroPago() para la entrada de detalles de transferencia
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> mostrarDialogoRegistroPago(BuildContext context) async {
    String montoPago = "";

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registrar Pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  montoPago = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Monto del pago',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aquí puedes realizar la lógica de registrar el pago con el monto ingresado
                // Por ejemplo, puedes llamar a una función que maneje el pago y la actualización del estado
                // handlePayment(double.parse(montoPago));
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
