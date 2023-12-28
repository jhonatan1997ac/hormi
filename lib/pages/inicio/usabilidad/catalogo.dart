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
      name: 'Adoquin de cruz',
      description: 'Descripción del Producto 1',
      imageUrl: 'assets/cruz.jpg',
      sizes: ['unidad', 'metro', 'paleta'],
    ),
    Product(
      name: 'Adoquin de paleta',
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
        title: const Text('Catálogo de Productos'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              SizedBox(
                height: 89, // Ajusta la altura de la sección de la imagen
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color.fromARGB(0, 136, 63, 63),
                        Colors.black.withOpacity(0.7)
                      ],
                    ),
                  ),
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SmallButton(
                      label: 'Comprar',
                      onPressed: () {
                        // Acción al presionar el botón de compra
                      },
                    ),
                    SmallButton(
                      label: 'Detalles',
                      onPressed: () {
                        // Acción al presionar el botón de detalles
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        textStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // Ajusta el tamaño aquí
      ),
      child: Text(label),
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
      (product) => product.name.toLowerCase().contains(query.toLowerCase()),
    );

    return ProductSearchResults(results.toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products.where(
      (product) => product.name.toLowerCase().contains(query.toLowerCase()),
    );

    return ProductSearchResults(suggestions.toList());
  }
}

class ProductSearchResults extends StatelessWidget {
  final List<Product> results;

  const ProductSearchResults(this.results, {super.key});

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
