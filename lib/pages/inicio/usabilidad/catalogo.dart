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
      sizes: ['unidad', 'metro', 'paleta'],
    ),
    Product(
      name: 'Producto 2',
      description: 'Descripción del Producto 2',
      imageUrl: 'assets/paleta.jpg',
      sizes: ['Small', 'Medium'],
    ),
    // Agrega más productos según sea necesario
  ];

  Catalogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
      ),
      body: Container(
        color: Colors.white, // Fondo blanco
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Fondo blanco
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: ProductSearchDelegate(products),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                // Acción al presionar el botón de carrito de compras
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Acción al presionar el botón de perfil de usuario
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción al presionar el botón flotante
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          SizedBox(height: 8), // Añade un pequeño espacio
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SmallButton(
                      label: 'Button 1',
                      onPressed: () {
                        // Acción al presionar el botón 1
                      },
                    ),
                    SmallButton(
                      label: 'Button 2',
                      onPressed: () {
                        // Acción al presionar el botón 2
                      },
                    ),
                    SmallButton(
                      label: 'Button 3',
                      onPressed: () {
                        // Acción al presionar el botón 3
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SmallButton({Key? key, required this.label, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        textStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class ProductSearchDelegate extends SearchDelegate<Product> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, query as Product);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products.where(
        (product) => product.name.toLowerCase().contains(query.toLowerCase()));

    return ProductSearchResults(results.toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products.where(
        (product) => product.name.toLowerCase().contains(query.toLowerCase()));

    return ProductSearchResults(suggestions.toList());
  }
}

class ProductSearchResults extends StatelessWidget {
  final List<Product> results;

  ProductSearchResults(this.results);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          onTap: () {
            // Acción al seleccionar un resultado de búsqueda
          },
        );
      },
    );
  }
}
