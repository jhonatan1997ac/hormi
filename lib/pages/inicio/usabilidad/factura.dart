import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Enumeración para los tipos de productos
enum ProductType {
  unidad,
  paleta,
  metros,
}

// Clase para representar un producto
class Product {
  final String name;
  final double price;
  ProductType type;
  int quantity;

  // Constructor del producto
  Product({
    required this.name,
    required this.price,
    required this.type,
    this.quantity = 1,
  });
}

// Clase para representar una factura
class Factura {
  final String nombreCliente;
  final String direccionCliente;
  final String nombreEmpresa;
  final String direccionEmpresa;
  final String numeroFactura;
  final DateTime fechaFactura;
  final List<Product> productos;

  // Constructor de la factura
  Factura({
    required this.nombreCliente,
    required this.direccionCliente,
    required this.nombreEmpresa,
    required this.direccionEmpresa,
    required this.numeroFactura,
    required this.fechaFactura,
    required this.productos,
  });

  // Método para calcular el total de la factura
  double calcularTotal() {
    return productos.fold(
        0, (total, product) => total + (product.price * product.quantity));
  }

  // Método para imprimir la factura
  void imprimirFactura() {
    if (kDebugMode) {
      print('Factura No. $numeroFactura');
      print('Fecha de Emisión: ${_formatDate(fechaFactura)}');
      print('Nombre de la Empresa: $nombreEmpresa');
      print('Dirección de la Empresa: $direccionEmpresa');
      print('Cliente: $nombreCliente');
      print('Dirección del Cliente: $direccionCliente');
    }
    if (kDebugMode) {
      print('Productos:');
    }
    for (var product in productos) {
      if (kDebugMode) {
        print(
            '${product.name} - ${product.quantity} ${_getTypeString(product.type)}: \$${product.price}');
      }
    }
    if (kDebugMode) {
      print('Total: \$${calcularTotal()}');
    }
  }

  // Método privado para obtener una cadena representando el tipo de producto
  String _getTypeString(ProductType type) {
    switch (type) {
      case ProductType.unidad:
        return 'unidad';
      case ProductType.paleta:
        return 'paleta';
      case ProductType.metros:
        return 'metros';
      default:
        return '';
    }
  }

  // Método privado para formatear la fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Pantalla principal para la selección de productos y generación de factura
class FacturacionScreen extends StatefulWidget {
  const FacturacionScreen({Key? key}) : super(key: key);

  @override
  _FacturacionScreenState createState() => _FacturacionScreenState();
}

class _FacturacionScreenState extends State<FacturacionScreen> {
  List<Product> productos = [
    Product(name: 'Adoquin de cruz', price: 0.45, type: ProductType.unidad),
    Product(name: 'Adoquin de paleta', price: 60.0, type: ProductType.unidad),
    Product(name: 'Adoquin de metro', price: 20.0, type: ProductType.metros),
  ];

  List<Product> productosSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facturación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccione los productos para la factura:'),

            // Usar CheckboxListTile para mostrar la lista de productos
            for (var i = 0; i < productos.length; i++)
              CheckboxListTile(
                title: Text('${productos[i].name} (\$${productos[i].price})'),
                value: productosSeleccionados.contains(productos[i]),
                onChanged: (value) {
                  if (value != null && value) {
                    // Llamar al método para obtener cantidad y tipo del usuario
                    _getCantidadYTipoDelUsuario(context, productos[i]);
                    setState(() {
                      productosSeleccionados.add(productos[i]);
                    });
                  } else {
                    setState(() {
                      productosSeleccionados.remove(productos[i]);
                    });
                  }
                },
              ),

            // Botón para generar la factura
            ElevatedButton(
              onPressed: () {
                _mostrarFactura(context);
              },
              child: const Text('Generar Factura'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obtener cantidad y tipo del usuario mediante un diálogo
  void _getCantidadYTipoDelUsuario(
      BuildContext context, Product producto) async {
    await showDialog(
      context: context,
      builder: (context) {
        int cantidad = producto.quantity;
        ProductType tipoSeleccionado = producto.type;

        return AlertDialog(
          title: Text('Ingrese la cantidad y tipo para ${producto.name}:'),
          content: Column(
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  try {
                    cantidad = int.parse(value.trim());
                  } catch (e) {
                    cantidad = 1;
                  }
                },
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              DropdownButtonFormField(
                value: tipoSeleccionado,
                items: ProductType.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Text(_getTypeString(tipo)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value is ProductType) {
                    setState(() {
                      tipoSeleccionado = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  producto.quantity = cantidad;
                  producto.type = tipoSeleccionado;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar la factura generada
  void _mostrarFactura(BuildContext context) {
    String nombreCliente = 'Cliente Ejemplo';
    String direccionCliente = 'Dirección de Ejemplo';
    String nombreEmpresa = 'Empresa Grande S.A.';
    String direccionEmpresa = 'Dirección de la Empresa Grande';
    String numeroFactura = '123456';
    DateTime fechaFactura = DateTime.now();

    Factura facturaGenerada = Factura(
      nombreCliente: nombreCliente,
      direccionCliente: direccionCliente,
      nombreEmpresa: nombreEmpresa,
      direccionEmpresa: direccionEmpresa,
      numeroFactura: numeroFactura,
      fechaFactura: fechaFactura,
      productos: productosSeleccionados,
    );

    if (kDebugMode) {
      print('\nNueva Factura Generada:');
    }
    facturaGenerada.imprimirFactura();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacturaScreen(factura: facturaGenerada),
      ),
    );
  }

  // Método privado para obtener una cadena representando el tipo de producto
  String _getTypeString(ProductType tipo) {
    switch (tipo) {
      case ProductType.unidad:
        return 'unidad';
      case ProductType.paleta:
        return 'paleta';
      case ProductType.metros:
        return 'metros';
      default:
        return '';
    }
  }
}

// Pantalla para mostrar los detalles de la factura generada
class FacturaScreen extends StatelessWidget {
  final Factura factura;

  const FacturaScreen({required this.factura, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Factura'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Información del cliente
            ListTile(
              title: Text('Cliente: ${factura.nombreCliente}'),
              subtitle: Text('Dirección: ${factura.direccionCliente}'),
            ),

            const Divider(),

            // Información de la empresa
            ListTile(
              title: Text('Empresa: ${factura.nombreEmpresa}'),
              subtitle:
                  Text('Dirección de la Empresa: ${factura.direccionEmpresa}'),
            ),

            const Divider(),

            // Detalles de la factura
            ListTile(
              title: Text('Factura No.: ${factura.numeroFactura}'),
              subtitle: Text(
                  'Fecha de Emisión: ${_formatDate(factura.fechaFactura)}'),
            ),

            const Divider(),

            // Lista de productos en la factura
            for (var producto in factura.productos)
              ListTile(
                title: Text(
                    '${producto.name} - ${producto.quantity} ${_getTypeString(producto.type)}: \$${producto.price}'),
                subtitle:
                    Text('Total: \$${producto.quantity * producto.price}'),
              ),

            // Mostrar el total
            const SizedBox(height: 16),
            Text('Total: \$${factura.calcularTotal()}'),
          ],
        ),
      ),
    );
  }

  // Método privado para obtener una cadena representando el tipo de producto
  String _getTypeString(ProductType tipo) {
    switch (tipo) {
      case ProductType.unidad:
        return 'unidad';
      case ProductType.paleta:
        return 'paleta';
      case ProductType.metros:
        return 'metros';
      default:
        return '';
    }
  }

  // Método privado para formatear la fecha
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
