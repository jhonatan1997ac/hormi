import 'package:flutter/material.dart';

class Configuracion extends StatefulWidget {
  @override
  _ConfiguracionState createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  bool modoOscuro = false;
  String idiomaSeleccionado = 'Español';
  double tamanoTexto = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ajustes de la Aplicación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SwitchListTile(
              title: Text('Modo Oscuro'),
              value: modoOscuro,
              onChanged: (value) {
                setState(() {
                  modoOscuro = value;
                  _aplicarModoOscuro(); // Función para aplicar el modo oscuro
                });
              },
            ),
            SizedBox(height: 10),
            _buildIdiomaDropdown(), // Función para construir el selector de idioma
            SizedBox(height: 10),
            _buildTamanoTextoSlider(), // Función para construir el slider del tamaño del texto
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _guardarConfiguracion(); // Función para guardar la configuración
              },
              child: Text('Guardar Configuración'),
            ),
          ],
        ),
      ),
    );
  }

  void _aplicarModoOscuro() {
    // Implementa aquí la lógica para cambiar el tema de la aplicación según el valor de modoOscuro
    // Ejemplo: Theme.of(context).brightness = modoOscuro ? Brightness.dark : Brightness.light;
  }

  Widget _buildIdiomaDropdown() {
    return ListTile(
      title: Text('Idioma'),
      subtitle: DropdownButton<String>(
        value: idiomaSeleccionado,
        onChanged: (String? newValue) {
          setState(() {
            idiomaSeleccionado = newValue!;
          });
        },
        items: ['Español', 'Inglés', 'Francés', 'Alemán']
            .map<DropdownMenuItem<String>>(
              (String value) => DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTamanoTextoSlider() {
    return ListTile(
      title: Text('Tamaño del Texto'),
      subtitle: Slider(
        value: tamanoTexto,
        min: 10.0,
        max: 30.0,
        onChanged: (value) {
          setState(() {
            tamanoTexto = value;
          });
        },
      ),
    );
  }

  void _guardarConfiguracion() {
    // Implementa aquí la lógica para guardar la configuración en algún lugar
    _mostrarMensaje('Configuración guardada correctamente.');
  }

  void _mostrarMensaje(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mensaje'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Configuracion(),
    ),
  );
}
