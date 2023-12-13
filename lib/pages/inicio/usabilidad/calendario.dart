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
          return CircularProgressIndicator();
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
                  subtitle: Text(event.task),
                );
              },
            ),
          );
        }
      },
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, DateTime date) async {
    String task = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Tarea'),
          content: TextField(
            onChanged: (value) {
              task = value;
            },
            decoration: const InputDecoration(labelText: 'Nombre de la tarea'),
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
                await _calendarData.addEvent(date, task);
                Navigator.of(context).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }
}

class CalendarData {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<DateTime, List<String>> events;

  CalendarData({Map<DateTime, List<String>> events = const {}})
      // ignore: prefer_initializing_formals
      : events = events;

  Future<void> addEvent(DateTime date, String task) async {
    try {
      await _firestore.collection('events').add({
        'date': date,
        'task': task,
      });
    } catch (e) {
      print('Error adding event: $e');
    }
  }

  Stream<List<Event>> getEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event(date: data['date'].toDate(), task: data['task']);
      }).toList();
    });
  }

  int get totalTasks {
    // Puedes seguir usando el método anterior o calcular el total a partir de los eventos en Firestore.
    // Dejo esto como un ejemplo, pero puedes ajustarlo según tus necesidades.
    // Si usas Firestore, el total de tareas se obtendría desde el stream de eventos.
    return 0;
  }
}

class Event {
  final DateTime date;
  final String task;

  Event({required this.date, required this.task});
}

class TareaPage extends StatelessWidget {
  final CalendarData calendarData;

  const TareaPage({Key? key, required this.calendarData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tarea(calendarData: calendarData);
  }
}

class Tarea extends StatelessWidget {
  final CalendarData calendarData;

  const Tarea({Key? key, required this.calendarData}) : super(key: key);

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
