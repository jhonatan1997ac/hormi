import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(const CalendarApp());
}

class CalendarApp extends StatelessWidget {
  const CalendarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Calendario(),
    );
  }
}

class Calendario extends StatefulWidget {
  const Calendario({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late DateTime _selectedDate;
  final CalendarData _calendarData = CalendarData();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Tareas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Año: ${_selectedDate.year} - Mes: ${_selectedDate.month}'),
            const SizedBox(height: 16),
            _buildEventList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return StreamBuilder<List<Event>>(
      stream: _calendarData.getEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final events = snapshot.data ?? [];
          return Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text('Fecha: ${event.date}'),
                  subtitle: Text(
                      'Producto: ${event.productName}, Cantidad: ${event.quantity}, Estado: ${event.status}'),
                  onTap: () {
                    // Navegar a la pantalla de ListaTareas
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ListaTareas(calendarData: _calendarData),
                      ),
                    );
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  // ignore: unused_element
  Future<void> _showAddDeliveryDialog(
      BuildContext context, DateTime date) async {
    String productName = '';
    int quantity = 0;
    String status = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Entrega'),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  productName = value;
                },
                decoration:
                    const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 0;
                },
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                onChanged: (value) {
                  status = value;
                },
                decoration: const InputDecoration(labelText: 'Estado'),
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
              onPressed: () async {
                await _calendarData.addEvent(
                    date, productName, quantity, status);
                // Navegar a la pantalla de AgregarTarea
                // ignore: use_build_context_synchronously
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgregarTarea(
                        selectedDate: date, calendarData: _calendarData),
                  ),
                );
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}

class ListaTareas extends StatelessWidget {
  final CalendarData calendarData;

  const ListaTareas({Key? key, required this.calendarData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: Column(
        children: [
          Text('Número total de tareas: ${calendarData.totalTasks}'),
          Expanded(
            child: ListView.builder(
              itemCount: calendarData.events.length,
              itemBuilder: (context, index) {
                final date = calendarData.events.keys.toList()[index];
                final tasks = calendarData.events[date] ?? [];

                return ListTile(
                  title: Text('Fecha: $date'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: tasks.map((task) => Text(task)).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AgregarTarea extends StatelessWidget {
  final DateTime selectedDate;
  final CalendarData calendarData;

  const AgregarTarea({
    Key? key,
    required this.selectedDate,
    required this.calendarData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              onChanged: (value) {
                // Actualizar el nombre de la tarea
              },
              decoration:
                  const InputDecoration(labelText: 'Nombre de la Tarea'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Lógica para agregar la tarea
                Navigator.of(context).pop();
              },
              child: const Text('Agregar Tarea'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(DateTime date, String productName, dynamic quantity,
      String status) async {
    try {
      // Convertir la fecha a formato Timestamp
      Timestamp timestamp = Timestamp.fromDate(date);

      // Verificar y convertir quantity a un valor numérico antes de agregarlo al mapa
      int quantityValue;
      if (quantity is int) {
        quantityValue = quantity;
      } else if (quantity is String) {
        quantityValue = int.tryParse(quantity) ?? 0;
      } else {
        quantityValue = 0; // Puedes manejar otro caso según tus necesidades
      }

      // Agregar el evento a la colección 'events'
      await _firestore.collection('events').add({
        'date': timestamp,
        'productName': productName,
        'quantity': quantityValue,
        'status': status,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding event: $e');
      }
    }
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // ignore: unnecessary_cast
        final data = doc.data() as Map<String, dynamic>;

        // Imprime los datos para depuración
        if (kDebugMode) {
          print('Datos recuperados de Firestore: $data');
        }

        final productName = data['productName'];

        if (productName is String) {
          // Haz algo con la cadena productName
          if (kDebugMode) {
            print('Nombre del producto: $productName');
          }
        } else {
          // El campo 'productName' no es una cadena
          if (kDebugMode) {
            print('Error: productName no es una cadena');
          }
          // Intenta convertir productName a String antes de asignarlo
          if (kDebugMode) {
            print('productName convertido a cadena: ${productName.toString()}');
          }
        }

        return Event(
          date: data['date'].toDate(),
          productName: data['productName'],
          quantity: data['quantity'], // Ahora puede ser int o String
          status: data['status'],
        );
      }).toList();
    });
  }

  int get totalTasks {
    // Puedes seguir usando el método anterior o calcular el total a partir de los eventos en Firestore.
    // Dejo esto como un ejemplo, pero puedes ajustarlo según tus necesidades.
    // Si usas Firestore, el total de tareas se obtendría desde el stream de eventos.
    return 0;
  }

  Map<DateTime, List<String>> get events {
    // Implementa la lógica para obtener los eventos en forma de Map<DateTime, List<String>>
    return {};
  }
}

class Event {
  final DateTime date;
  final String productName;
  final dynamic quantity;
  final String status;

  Event({
    required this.date,
    required this.productName,
    required this.quantity,
    required this.status,
  });
}
