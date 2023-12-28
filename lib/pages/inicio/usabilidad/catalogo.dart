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

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class Catalogo extends StatefulWidget {
  Catalogo({Key? key}) : super(key: key);

  @override
  _CatalogoState createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  List<Product> products = [
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

  List<CartItem> cartItems = [];

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
          return ProductCard(product: products[index], onAddToCart: addToCart);
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
                showCartDialog(context);
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

  void addToCart(Product product) {
    // Busca si el producto ya está en el carrito
    var cartItem = cartItems.firstWhere(
      (item) => item.product.name == product.name,
      orElse: () => CartItem(product: product),
    );

    // Si el producto ya está en el carrito, muestra el diálogo de cantidad
    if (cartItems.contains(cartItem)) {
      showQuantityDialog(cartItem);
    } else {
      // Si el producto no está en el carrito, agrégalo directamente con la cantidad predeterminada
      setState(() {
        cartItems.add(cartItem);
      });
    }
  }

  Future<void> showQuantityDialog(CartItem cartItem) async {
    TextEditingController quantityController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cantidad de ${cartItem.product.name}'),
          content: Column(
            children: [
              const Text('Seleccione la cantidad:'),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
              ),
            ],
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
                String quantityText = quantityController.text.trim();
                if (quantityText.isNotEmpty) {
                  int quantity = int.parse(quantityText);
                  if (quantity > 0) {
                    setState(() {
                      cartItem.quantity = quantity;
                    });
                  }
                }
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void showCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CartDialog(cartItems: cartItems);
      },
    );
  }
}

class CartDialog extends StatelessWidget {
  final List<CartItem> cartItems;

  CartDialog({required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Carrito de Compras'),
      content: Column(
        children: cartItems
            .map((item) => Text('${item.product.name} x${item.quantity}'))
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cerrar'),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart;

  const ProductCard(
      {Key? key, required this.product, required this.onAddToCart})
      : super(key: key);

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
                height: 89,
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
                        onAddToCart(product);
                      },
                    ),
                    SmallButton(
                      label: 'Detalles',
                      onPressed: () {
                        showProductDetails(context, product);
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

  void showProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
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
        close(context,
            Product(name: '', description: '', imageUrl: '', sizes: []));
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

  const ProductSearchResults(this.results, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index].name),
          onTap: () {
            showProductDetails(context, results[index]);
          },
        );
      },
    );
  }

  void showProductDetails(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            product.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tamaños disponibles:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
