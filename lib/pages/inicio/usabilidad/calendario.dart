import 'package:flutter/material.dart';

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
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late DateTime _selectedDate;
  final CalendarData _calendarData = CalendarData({});

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
            CalendarWidget(
              calendarData: _calendarData,
              selectedDate: _selectedDate,
              onDateTapped: (date) => _showAddTaskDialog(context, date),
              onMonthChanged: (newMonth) {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, newMonth, 1);
                });
              },
            ),
            const SizedBox(height: 16),
            Text('Número total de tareas: ${_calendarData.totalTasks}'),
          ],
        ),
      ),
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
              onPressed: () {
                _calendarData.addEvent(date, task);
                Navigator.of(context).pop();
                _navigateToTareaPage(context); // Navegar a la página de tareas
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToTareaPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TareaPage(calendarData: _calendarData),
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final CalendarData calendarData;
  final DateTime selectedDate;
  final Function(DateTime) onDateTapped;
  final Function(int) onMonthChanged;

  const CalendarWidget({
    Key? key,
    required this.calendarData,
    required this.selectedDate,
    required this.onDateTapped,
    required this.onMonthChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                onMonthChanged(selectedDate.month - 1);
              },
            ),
            Text(
              '${selectedDate.year}',
              style: Theme.of(context).textTheme.headline6,
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                onMonthChanged(selectedDate.month + 1);
              },
            ),
          ],
        ),
        TableCalendar(
          calendarData: calendarData,
          selectedDate: selectedDate,
          onDateTapped: onDateTapped,
        ),
      ],
    );
  }
}

class TableCalendar extends StatelessWidget {
  final CalendarData calendarData;
  final DateTime selectedDate;
  final Function(DateTime) onDateTapped;

  const TableCalendar({
    Key? key,
    required this.calendarData,
    required this.selectedDate,
    required this.onDateTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime firstDayOfMonth =
        DateTime(selectedDate.year, selectedDate.month, 1);
    final int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    final int startWeekday = firstDayOfMonth.weekday;

    return Table(
      children: List.generate(
        ((daysInMonth + startWeekday - 1) / 7).ceil(),
        (index) => TableRow(
          children: List.generate(
            7,
            (index2) {
              final day = index * 7 + index2 + 1 - startWeekday;
              if (day > 0 && day <= daysInMonth) {
                final date =
                    DateTime(selectedDate.year, selectedDate.month, day);
                final events = calendarData.getEvents(date);
                return TableCell(
                  child: InkWell(
                    onTap: () => onDateTapped(date),
                    child: Container(
                      height: 40,
                      color: Colors.grey[200],
                      child: Column(
                        children: [
                          Text('$day'),
                          if (events.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            for (final event in events) Text(event),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const TableCell(child: SizedBox());
              }
            },
          ),
        ),
      ),
    );
  }
}

class CalendarData {
  final Map<DateTime, List<String>> events;

  CalendarData(this.events);

  void addEvent(DateTime date, String task) {
    if (events.containsKey(date)) {
      events[date]!.add(task);
    } else {
      events[date] = [task];
    }
  }

  List<String> getEvents(DateTime date) {
    return events[date] ?? [];
  }

  int get totalTasks {
    return events.values.fold(0, (count, tasks) => count + tasks.length);
  }
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
