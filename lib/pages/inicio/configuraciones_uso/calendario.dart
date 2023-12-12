import 'package:apphormi/pages/inicio/usabilidad/calendario.dart';
import 'package:flutter/material.dart';

class CalendarDataProvider extends InheritedWidget {
  final CalendarData calendarData;

  const CalendarDataProvider({
    Key? key,
    required this.calendarData,
    required Widget child,
  }) : super(key: key, child: child);

  static CalendarDataProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CalendarDataProvider>();
  }

  @override
  bool updateShouldNotify(CalendarDataProvider oldWidget) {
    return oldWidget.calendarData != calendarData;
  }
}
