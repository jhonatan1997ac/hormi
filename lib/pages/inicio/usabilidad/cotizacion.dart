import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

enum ProductType {
  unidad,
  paleta,
  metros,
}

class Product {
  final String name;
  final double price;
  ProductType type;
  int quantity;

  Product({
    required this.name,
    required this.price,
    required this.type,
    this.quantity = 1,
  });
}

class Quotation {
  final String companyName;
  final List<Product> products;

  Quotation({required this.companyName, required this.products});

  double calculateTotal() {
    return products.fold(
        0, (total, product) => total + (product.price * product.quantity));
  }

  void printQuotation() {
    if (kDebugMode) {
      print('Cotización para: $companyName');
    }
    if (kDebugMode) {
      print('Productos:');
    }
    for (var product in products) {
      if (kDebugMode) {
        print(
            '${product.name} - ${product.quantity} ${_getTypeString(product.type)}: \$${product.price}');
      }
    }
    if (kDebugMode) {
      print('Total: \$${calculateTotal()}');
    }
  }

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
}

class CotizacionesScreen extends StatefulWidget {
  const CotizacionesScreen({Key? key}) : super(key: key);

  @override
  _CotizacionesScreenState createState() => _CotizacionesScreenState();
}

class _CotizacionesScreenState extends State<CotizacionesScreen> {
  List<Product> products = [
    Product(name: 'Adoquin de cruz', price: 0.45, type: ProductType.unidad),
    Product(name: 'Adoquin de paleta', price: 60.0, type: ProductType.unidad),
    Product(name: 'Adoquin de metro', price: 20.0, type: ProductType.metros),
  ];

  List<Product> selectedProducts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotizaciones y Pedidos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seleccione los productos para la cotización:'),
            for (var i = 0; i < products.length; i++)
              CheckboxListTile(
                title: Text('${products[i].name} (\$${products[i].price})'),
                value: selectedProducts.contains(products[i]),
                onChanged: (value) {
                  if (value != null && value) {
                    _getQuantityAndTypeFromUser(context, products[i]);
                    setState(() {
                      selectedProducts.add(products[i]);
                    });
                  } else {
                    setState(() {
                      selectedProducts.remove(products[i]);
                    });
                  }
                },
              ),
            ElevatedButton(
              onPressed: () {
                _showQuotation(context);
              },
              child: const Text('Generar Cotización'),
            ),
          ],
        ),
      ),
    );
  }

  void _getQuantityAndTypeFromUser(
      BuildContext context, Product product) async {
    await showDialog(
      context: context,
      builder: (context) {
        int quantity = product.quantity;
        ProductType selectedType = product.type;

        return AlertDialog(
          title: Text('Ingrese la cantidad y tipo para ${product.name}:'),
          content: Column(
            children: [
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  try {
                    quantity = int.parse(value.trim());
                  } catch (e) {
                    quantity = 1;
                  }
                },
                decoration: const InputDecoration(labelText: 'Cantidad'),
              ),
              DropdownButtonFormField(
                value: selectedType,
                items: ProductType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeString(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value is ProductType) {
                    setState(() {
                      selectedType = value;
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
                  product.quantity = quantity;
                  product.type = selectedType;
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

  void _showQuotation(BuildContext context) {
    String companyName = 'Empresa de Adoquines y Prefabricados';

    Quotation selectedQuotation =
        Quotation(companyName: companyName, products: selectedProducts);

    if (kDebugMode) {
      print('\nNueva Cotización Seleccionada:');
    }
    selectedQuotation.printQuotation();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuotationScreen(quotation: selectedQuotation),
      ),
    );
  }

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
}

class QuotationScreen extends StatelessWidget {
  final Quotation quotation;

  const QuotationScreen({required this.quotation, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Cotización'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var product in quotation.products)
              ListTile(
                title: Text(
                    '${product.name} - ${product.quantity} ${_getTypeString(product.type)}: \$${product.price}'),
                subtitle: Text('Total: \$${product.quantity * product.price}'),
              ),
            const SizedBox(height: 16),
            Text('Total: \$${quotation.calculateTotal()}'),
          ],
        ),
      ),
    );
  }

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
}
