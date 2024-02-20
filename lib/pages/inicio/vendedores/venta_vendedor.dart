// ignore_for_file: use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unnecessary_string_interpolations, sort_child_properties_last, library_private_types_in_public_api

import 'dart:io';

import 'package:apphormi/pages/inicio/vendedores/vendedor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
    tipoPagoSeleccionado = null;
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
                  style: const TextStyle(color: Colors.red),
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
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void mostrarMensajeEmergente(String mensaje, {Color color = Colors.white}) {
    OverlayEntry overlayEntry;

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
            color: color,
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
          'No hay suficiente cantidad disponible o el stock mínimo no se alcanza',
          color: Colors.green);
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
      if (kDebugMode) {
        print("Error al restar la cantidad en Firestore: $error");
      }
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
      if (kDebugMode) {
        print("Error al agregar al carrito: $error");
      }
    }
  }

  Future<void> registrarVentaEnHistorial(
    List<Producto> productos,
    double subtotal,
    double iva,
    double total,
    String metodoPago,
    String nombrePersona,
    String imagePath,
  ) async {
    try {
      CollectionReference historialVentasCollection =
          FirebaseFirestore.instance.collection('historialventas');

      await historialVentasCollection.add({
        'productos': productos.map((producto) {
          return {
            'producto_id': producto.id,
            'nombre': producto.nombre,
            'precio': producto.precio,
            'imagen': producto.imagen,
            'cantidad': producto.cantidad,
          };
        }).toList(),
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'metodoPago': metodoPago,
        'nombrePersona': nombrePersona,
        'imagen': imagePath,
        'fecha': DateTime.now(),
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error al registrar la venta en el historial: $error");
      }
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
                title: const Text('Pagar por Banca Móvil'),
                onTap: () {
                  Navigator.of(context).pop();
                  mostrarDialogDatosBancaMovil();
                },
              ),
              ListTile(
                title: const Text('Efectivo'),
                onTap: () {
                  Navigator.of(context).pop();
                  mostrarDialogDatosEfectivo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> mostrarDialogDatosBancaMovil() async {
    TextEditingController nombreController = TextEditingController();

    String? imagePath;

    Future<void> capturarImagen() async {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          imagePath = image.path;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingrese los Datos para Pagar por Banca Móvil'),
          content: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              if (imagePath != null)
                Image.file(
                  File(imagePath!),
                  height: 100,
                  width: 100,
                ),
              ElevatedButton(
                onPressed: capturarImagen,
                child: const Text('Tomar Foto'),
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
                String nombre = nombreController.text;
                if (nombre.isNotEmpty && imagePath != null) {
                  Navigator.of(context).pop();
                  registrarVentaEnHistorial(
                    carrito,
                    calcularSubtotal(carrito),
                    calcularIVA(carrito),
                    calcularTotal(carrito),
                    'Banca Móvil',
                    nombre,
                    imagePath!,
                  );
                } else {}
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> mostrarDialogDatosEfectivo() async {
    TextEditingController montoRecibidoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingrese los Datos de Efectivo'),
          content: Column(
            children: [
              TextField(
                controller: montoRecibidoController,
                decoration: const InputDecoration(labelText: 'Monto Recibido'),
                keyboardType: TextInputType.number,
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
                String montoRecibido = montoRecibidoController.text;

                if (montoRecibido.isNotEmpty) {
                  double montoRecibidoDouble = double.parse(montoRecibido);
                  double cambio = montoRecibidoDouble - calcularTotal(carrito);

                  mostrarMensajeEmergente('Cambio a entregar: $cambio',
                      color: Colors.green);

                  registrarVentaEnHistorial(
                    carrito,
                    calcularSubtotal(carrito),
                    calcularIVA(carrito),
                    calcularTotal(carrito),
                    'Efectivo',
                    '',
                    '',
                  );

                  Navigator.of(context).pop();
                } else {}
              },
              child: const Text('Aceptar'),
            ),
          ],
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
        title: const Text(
          "Ventas",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const VendedorHome()),
            );
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.black,
            size: 30.0,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 55, 111, 139),
              Color.fromARGB(255, 165, 160, 160),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 85, 142, 165),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Productos Disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 250, 250, 250),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: productosDisponibles.length,
                  itemBuilder: (context, index) {
                    final producto = productosDisponibles[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Cantidad: ${producto.cantidad}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '\$${producto.precio.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
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
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 85, 142, 165),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 161, 157, 157)
                          .withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Carrito de Compras',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 250, 250, 250),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: carrito.length,
                  itemBuilder: (context, index) {
                    final producto = carrito[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          '${producto.nombre}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${producto.precio.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Cantidad: ${producto.cantidad}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        leading: SizedBox(
                          width: 50.0,
                          child: producto.imagen != null
                              ? Image.network(producto.imagen!)
                              : const Placeholder(),
                        ),
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
                    if (tipoPagoSeleccionado == 'Banca Móvil') {
                      mostrarDialogDatosBancaMovil();
                    } else if (tipoPagoSeleccionado == 'Efectivo') {
                      mostrarDialogDatosEfectivo();
                    } else {
                      mostrarMensajeEmergente(
                          'Tipo de pago no reconocido: $tipoPagoSeleccionado');
                    }
                  }
                },
                child: const Text('Enviar Venta'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 241, 241, 241),
                  backgroundColor: tipoPagoSeleccionado == null
                      ? const Color.fromARGB(255, 39, 34, 34)
                      : const Color.fromARGB(255, 1, 243, 142),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                  'Tipo de Pago Seleccionado: ${tipoPagoSeleccionado ?? "Ninguno"}'),
            ],
          ),
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
