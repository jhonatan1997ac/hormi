import 'package:flutter/material.dart';

class Product {
  final String name;
  final String description;
  final String imageUrl;
  final List<String> sizes;

  Product({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.sizes,
  });
}

class Catalogo extends StatelessWidget {
  final List<Product> products = [
    Product(
      name: 'Producto 1',
      description: 'Descripción del Producto 1',
      imageUrl: 'assets/cruz.jpg',
      sizes: ['Small', 'Medium', 'Large'],
    ),
    Product(
      name: 'Producto 2',
      description: 'Descripción del Producto 2',
      imageUrl: 'assets/paleta.jpg',
      sizes: ['Small', 'Medium'],
    ),
    // Agrega más productos según sea necesario
  ];

  Catalogo({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: products[index]);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              product.imageUrl,
              fit: BoxFit.cover,
              height: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tamaños disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: product.sizes
                      .map(
                        (size) => Chip(
                          label: Text(size),
                          backgroundColor: Colors.blue,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
