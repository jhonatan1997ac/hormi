import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String? imagen;
  int cantidad;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    this.imagen,
    required this.cantidad,
  });
}

class HistorialVenta {
  final List<Map<String, dynamic>> productos;
  final double subtotal;
  final double iva;
  final double total;
  final String metodoPago;
  final DateTime fecha;

  HistorialVenta({
    required this.productos,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.metodoPago,
    required this.fecha,
  });
}

class Ventas extends StatefulWidget {
  const Ventas({Key? key}) : super(key: key);

  @override
  _VentasState createState() => _VentasState();
}

class _VentasState extends State<Ventas> {
  List<Producto> productosDisponibles = [];
  List<Producto> carrito = [];
  String? tipoPagoSeleccionado;
  String? errorMessage;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    cargarProductosDesdeFirestore();
  }

  Future<void> cargarProductosDesdeFirestore() async {
    CollectionReference disponibilidadproductoCollection =
        FirebaseFirestore.instance.collection('disponibilidadproducto');

    QuerySnapshot querySnapshot = await disponibilidadproductoCollection.get();

    List<Producto> productos = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Producto(
        id: doc.id,
        nombre: data['nombre'] ?? '',
        precio: (data['precio'] ?? 0.0).toDouble(),
        imagen: data['imagen'],
        cantidad: data['cantidad'] ?? 0,
      );
    }).toList();

    setState(() {
      productosDisponibles = productos;
    });
  }

  Future<void> mostrarDialogCantidad(Producto producto) async {
    int selectedQuantity = 1;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cantidad de Productos'),
          content: Column(
            children: [
              Text(
                  'Ingrese la cantidad de ${producto.nombre} que desea comprar:'),
              TextField(
                controller:
                    TextEditingController(text: selectedQuantity.toString()),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int? parsedValue = int.tryParse(value);
                  if (parsedValue != null && parsedValue > 0) {
                    selectedQuantity = parsedValue;
                  } else {
                    setState(() {
                      errorMessage = 'La cantidad no puede ser negativa';
                    });
                  }
                },
              ),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
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
              onPressed: () async {
                if (await verificarDisponibilidad(producto, selectedQuantity)) {
                  agregarAlCarrito(producto, selectedQuantity);
                  // Cerrar el diálogo antes de registrar en historial
                  Navigator.of(context).pop();
                  // Guardar en el historial de ventas
                  registrarVentaEnHistorial(
                    carrito,
                    calcularSubtotal(carrito),
                    calcularIVA(carrito),
                    calcularTotal(carrito),
                    tipoPagoSeleccionado ?? 'Sin especificar',
                  );
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void mostrarMensajeEmergente(String mensaje) {
    OverlayEntry overlayEntry;

    // Calcula la posición vertical para centrar la superposición debajo del número ingresado
    double overlayTop = MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).size.height * 0.12;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: overlayTop,
        width: MediaQuery.of(context).size.width,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50),
            color: Colors.red,
            child: Center(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }

  Future<bool> verificarDisponibilidad(
      Producto producto, int selectedQuantity) async {
    if (producto.cantidad >= selectedQuantity &&
        (producto.cantidad - selectedQuantity) >= 10) {
      setState(() {
        errorMessage = null;
      });
      return true;
    } else {
      mostrarMensajeEmergente(
          'No hay suficiente cantidad disponible o el stock mínimo no se alcanza');
      return false;
    }
  }

  Future<void> restarCantidadEnFirestore(
      Producto producto, int quantityToSubtract) async {
    try {
      DocumentReference productoRef = FirebaseFirestore.instance
          .collection('disponibilidadproducto')
          .doc(producto.id);

      DocumentSnapshot snapshot = await productoRef.get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('El producto no existe en la base de datos.'),
          ),
        );
        return;
      }

      int cantidadActual = snapshot['cantidad'] ?? 0;
      if (cantidadActual >= quantityToSubtract) {
        await productoRef
            .update({'cantidad': FieldValue.increment(-quantityToSubtract)});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay suficiente cantidad disponible'),
          ),
        );
      }

      await cargarProductosDesdeFirestore();
    } catch (error) {
      print("Error al restar la cantidad en Firestore: $error");
    }
  }

  Future<void> agregarAlCarrito(Producto producto, int quantity) async {
    try {
      await restarCantidadEnFirestore(producto, quantity);

      setState(() {
        carrito.add(
          Producto(
            id: producto.id,
            nombre: producto.nombre,
            precio: producto.precio,
            imagen: producto.imagen,
            cantidad: quantity,
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito'),
        ),
      );
    } catch (error) {
      print("Error al agregar al carrito: $error");
    }
  }

  Future<void> registrarVentaEnHistorial(List<Producto> productos,
      double subtotal, double iva, double total, String? metodoPago) async {
    try {
      if (metodoPago == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Debe seleccionar un método de pago antes de enviar.'),
          ),
        );
        return;
      }

      if (tipoPagoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Debe seleccionar un tipo de pago antes de enviar la venta.'),
          ),
        );
        return;
      }

      CollectionReference historialVentasCollection =
          FirebaseFirestore.instance.collection('historial_ventas');

      await historialVentasCollection.add({
        'productos': productos
            .map((producto) => {
                  'producto_id': producto.id,
                  'nombre': producto.nombre,
                  'precio': producto.precio,
                  'imagen': producto.imagen,
                  'cantidad': producto.cantidad,
                })
            .toList(),
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'metodoPago': metodoPago,
        'fecha': DateTime.now(),
      });
      // Limpiar el carrito después de enviar la venta
      setState(() {
        carrito = [];
      });
      setState(() {
        tipoPagoSeleccionado = null;
      });
    } catch (error) {
      print("Error al registrar la venta en el historial: $error");
    }
  }

  Future<void> mostrarDialogTipoPago() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccione el Tipo de Pago'),
          content: Column(
            children: [
              ListTile(
                title: const Text('Tarjeta'),
                onTap: () {
                  setState(() {
                    tipoPagoSeleccionado = 'Tarjeta ';
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('Efectivo'),
                onTap: () {
                  setState(() {
                    tipoPagoSeleccionado = 'Efectivo';
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  double calcularSubtotal(List<Producto> productos) {
    return productos.fold(0.0, (subtotal, producto) {
      return subtotal + producto.precio * producto.cantidad;
    });
  }

  double calcularIVA(List<Producto> productos) {
    return calcularSubtotal(productos) * 0.16;
  }

  double calcularTotal(List<Producto> productos) {
    return calcularSubtotal(productos) + calcularIVA(productos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Ventas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Productos Disponibles'),
            Expanded(
              child: ListView.builder(
                itemCount: productosDisponibles.length,
                itemBuilder: (context, index) {
                  final producto = productosDisponibles[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${producto.nombre} '),
                        Text('Cantidad: ${producto.cantidad}'),
                        Text('\$${producto.precio.toStringAsFixed(2)}'),
                        ElevatedButton(
                          onPressed: () {
                            mostrarDialogCantidad(producto);
                          },
                          child: const Text('Agregar al Carrito'),
                        ),
                      ],
                    ),
                    leading: SizedBox(
                      width: 50.0,
                      child: producto.imagen != null
                          ? Image.network(producto.imagen!)
                          : const Placeholder(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Carrito de Compras'),
            Expanded(
              child: ListView.builder(
                itemCount: carrito.length,
                itemBuilder: (context, index) {
                  final producto = carrito[index];
                  return ListTile(
                    title: Text('${producto.nombre} '),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('\$${producto.precio.toStringAsFixed(2)}'),
                        Text('Cantidad: ${producto.cantidad}'),
                      ],
                    ),
                    leading: SizedBox(
                      width: 50.0,
                      child: producto.imagen != null
                          ? Image.network(producto.imagen!)
                          : const Placeholder(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                mostrarDialogTipoPago();
              },
              child: const Text('Escoger Tipo de Pago'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (tipoPagoSeleccionado == null) {
                  mostrarDialogTipoPago();
                } else {
                  registrarVentaEnHistorial(
                    carrito,
                    calcularSubtotal(carrito),
                    calcularIVA(carrito),
                    calcularTotal(carrito),
                    tipoPagoSeleccionado,
                  );
                }
              },
              child: const Text('Enviar Venta'),
              style: ElevatedButton.styleFrom(
                onPrimary: const Color.fromARGB(255, 241, 241, 241),
                primary: tipoPagoSeleccionado == null
                    ? const Color.fromARGB(255, 39, 34, 34)
                    : Color.fromARGB(255, 1, 243, 142),
              ),
            ),
            const SizedBox(height: 16),
            Text(
                'Tipo de Pago Seleccionado: ${tipoPagoSeleccionado ?? "Ninguno"}'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Ventas(),
  ));
}
