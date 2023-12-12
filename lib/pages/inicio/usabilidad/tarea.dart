import 'package:apphormi/pages/inicio/usabilidad/calendario.dart';
import 'package:flutter/material.dart';

class Tarea extends StatelessWidget {
  final CalendarData calendarData;

  const Tarea({Key? key, required this.calendarData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Tareas'),
      ),
      body: ListView.builder(
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
    );
  }
}
