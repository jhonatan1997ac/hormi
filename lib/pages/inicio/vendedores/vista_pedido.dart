// ignore_for_file: use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class VistaPedidos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'es_EC';
    initializeDateFormatting(Intl.defaultLocale);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista de Pedidos'),
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('pedidorealizado')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay pedidos realizados.'));
          }
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.blue[700]!),
                headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
                dataRowColor: MaterialStateColor.resolveWith(
                    (states) => Colors.blue[200]!),
                dataTextStyle:
                    const TextStyle(fontSize: 14, color: Colors.black),
                columnSpacing: 20.0,
                horizontalMargin: 20.0,
                dividerThickness: 1.5,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade400, width: 1.5),
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.blue[100],
                ),
                columns: const [
                  DataColumn(
                    label: Text('ID Pedido',
                        style: TextStyle(color: Colors.white)),
                    tooltip: 'ID del pedido',
                  ),
                  DataColumn(
                    label:
                        Text('Nombre', style: TextStyle(color: Colors.white)),
                    tooltip: 'Nombre del producto',
                  ),
                  DataColumn(
                    label:
                        Text('Cantidad', style: TextStyle(color: Colors.white)),
                    tooltip: 'Cantidad del producto',
                  ),
                  DataColumn(
                    label: Text('Días Necesarios',
                        style: TextStyle(color: Colors.white)),
                    tooltip: 'Días necesarios para el pedido',
                  ),
                  DataColumn(
                    label: Text('Fecha', style: TextStyle(color: Colors.white)),
                    tooltip: 'Fecha del pedido',
                  ),
                  DataColumn(
                    label:
                        Text('Calidad', style: TextStyle(color: Colors.white)),
                    tooltip: 'Calidad del producto',
                  ),
                  DataColumn(
                    label:
                        Text('Precio', style: TextStyle(color: Colors.white)),
                    tooltip: 'Precio del producto',
                  ),
                ],
                rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return DataRow(
                    color: MaterialStateColor.resolveWith(
                        (states) => Colors.blue[50]!),
                    cells: [
                      DataCell(
                        Text(data['idpedido'].toString(),
                            style: TextStyle(color: Colors.blue[800])),
                        onTap: () {
                          // Agregar lógica para manejar el clic en la celda del ID si es necesario
                        },
                      ),
                      DataCell(
                        Text(data['nombre'],
                            style: TextStyle(color: Colors.blue[800])),
                        onTap: () {
                          // Agregar lógica para manejar el clic en la celda del nombre si es necesario
                        },
                      ),
                      DataCell(Text(data['cantidad'].toString(),
                          style: TextStyle(color: Colors.blue[800]))),
                      DataCell(Text(data['diasNecesarios'].toString(),
                          style: TextStyle(color: Colors.blue[800]))),
                      DataCell(Text(
                          DateFormat('dd/MM/yyyy', Intl.defaultLocale).format(
                              data['fecha'].toDate().toUtc().add(const Duration(
                                  hours:
                                      -5))), // Convertir a UTC y ajustar a UTC-5
                          style: TextStyle(color: Colors.blue[800]))),
                      DataCell(Text(data['calidad'],
                          style: TextStyle(color: Colors.blue[800]))),
                      DataCell(Text('\$${data['precio'].toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.blue[800]))),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
