// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:apphormi/pages/inicio/vendedores/venta_vendedor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

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
                  subtitle: Row(
                    children: [
                      Text(
                        'Cantidad: ${producto.cantidad}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.network(
                        producto.imagen ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subtotal: \$${calcularSubtotal(carrito).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'IVA: \$${(calcularSubtotal(carrito) * 0.12).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Total: \$${(calcularSubtotal(carrito) * 1.12).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Productos:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: carrito.length,
                        itemBuilder: (context, index) {
                          final producto = carrito[index];
                          return Text(
                            '- ${producto.nombre} x${producto.cantidad}',
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Pagar',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
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
    double subtotal = calcularSubtotal(carrito);
    double iva = subtotal * 0.12;
    double total = subtotal + iva;

    List<Map<String, dynamic>> productos = carrito.map((producto) {
      return {
        'nombre': producto.nombre,
        'precio': producto.precio,
        'cantidad': producto.cantidad,
        'producto_id': const Uuid().v4(),
        'imagen': producto.imagen,
      };
    }).toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Resumen de Venta'),
          actions: [
            ListTile(
              title: const Text('Efectivo'),
              onTap: () {
                Navigator.of(context).pop();
                mostrarDialogoOpcionesEfectivo(
                  context,
                  productos,
                  subtotal,
                  iva,
                  total,
                  metodoPago: 'Efectivo', // Agregar el método de pago
                  nombrePersona: '', // Agregar el nombre de la persona
                  imagen: '', // Agregar la URL de la imagen
                );
              },
            ),
            ListTile(
              title: const Text('Registro de Pago'),
              onTap: () {
                Navigator.of(context).pop();
                mostrarDialogoOpcionesRegistropago(
                  context,
                  productos,
                  subtotal,
                  iva,
                  total,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void mostrarDialogoOpcionesEfectivo(
      BuildContext context,
      List<Map<String, dynamic>> productos,
      double subtotal,
      double iva,
      double total,
      {required String metodoPago,
      required String nombrePersona,
      required String imagen}) {
    List<int> denominaciones = [1, 2, 5, 10, 20, 50, 100, 200];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opciones de Pago en Efectivo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int denominacion in denominaciones)
                ElevatedButton(
                  onPressed: () {
                    if (denominacion >= total) {
                      double cambio = denominacion - total;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Cambio a devolver: \$${cambio.toStringAsFixed(2)}'),
                        ),
                      );

                      Future.delayed(const Duration(seconds: 0), () {
                        Navigator.of(context).pop();
                        carrito.clear();
                        enviarVentaAHistorial(
                          productos: productos,
                          subtotal: subtotal,
                          total: total,
                          iva: iva,
                          metodoPago: metodoPago,
                          nombrePersona: '',
                          imagen: '',
                          fecha: Timestamp.now(),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El monto ingresado es insuficiente.'),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$$denominacion',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const Icon(Icons.attach_money),
                    ],
                  ),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 18),
                    ),
                    Icon(Icons.cancel),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void enviarVentaAHistorial({
    required List<Map<String, dynamic>> productos,
    required double subtotal,
    required double iva,
    required double total,
    required String metodoPago,
    required String nombrePersona,
    required String imagen,
    required Timestamp fecha,
  }) async {
    try {
      CollectionReference historialVentas =
          FirebaseFirestore.instance.collection('historialventas');

      DocumentReference docRef = await historialVentas.add({
        'fecha': fecha,
        'productos': productos,
        'subtotal': subtotal,
        'iva': iva,
        'total': total,
        'metodoPago': metodoPago,
        'nombrePersona': nombrePersona,
        'imagen': imagen,
      });

      if (kDebugMode) {
        print('Venta registrada en el historial con ID: ${docRef.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error al enviar venta al historial: $e');
      }
    }
  }

  void mostrarDialogoOpcionesRegistropago(
    BuildContext context,
    List<Map<String, dynamic>> productos,
    double subtotal,
    double iva,
    double total,
  ) {
    TextEditingController nombreController = TextEditingController();
    File? imageFile;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Registro de Pago'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    const SizedBox(height: 10),
                    imageFile != null
                        ? Image.file(
                            imageFile!,
                            height: 100,
                          )
                        : const SizedBox(),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Seleccionar Fuente'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    GestureDetector(
                                      child: const Text('Cámara'),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.camera);
                                        if (image != null) {
                                          setState(() {
                                            imageFile = File(image.path);
                                          });
                                        }
                                      },
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                    ),
                                    GestureDetector(
                                      child: const Text('Galería'),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.gallery);
                                        if (image != null) {
                                          setState(() {
                                            imageFile = File(image.path);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tomar Foto',
                            style: TextStyle(fontSize: 18),
                          ),
                          Icon(Icons.camera_alt),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (total > 0) {
                          Navigator.of(context).pop();
                          var metodoPago = 'Registro de Pago';
                          var nombrePersona = nombreController
                              .text; // Obtener el valor del controlador
                          var imagen = ''; // Definir la URL de la imagen aquí
                          enviarVentaAHistorial(
                            productos: productos,
                            subtotal: subtotal,
                            iva: iva,
                            total: total,
                            metodoPago: metodoPago,
                            nombrePersona: nombrePersona,
                            imagen: imagen,
                            fecha: Timestamp.now(),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El monto total debe ser mayor que cero.',
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Aceptar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/historial_ventas');
                      },
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
