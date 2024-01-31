import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Notificacion(),
    );
  }
}

class Notificacion extends StatefulWidget {
  @override
  _NotificacionState createState() => _NotificacionState();
}

class _NotificacionState extends State<Notificacion> {
  late User? user;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<String> mensajes = [];
  final mensajeController = TextEditingController();
  String? selectedUser;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<List<String>> _cargarMensajes() async {
    try {
      QuerySnapshot mensajesSnapshot = await FirebaseFirestore.instance
          .collection('mensajes')
          .where('id_receptor', isEqualTo: user!.uid)
          .get();

      return mensajesSnapshot.docs
          .map((doc) => doc['contenido'].toString())
          .toList();
    } catch (e) {
      print("Error al cargar mensajes: $e");
      return [];
    }
  }

  Future<void> _mostrarNotificacion() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Ejemplo de cómo agregar un mensaje a Firestore
        await agregarMensaje(
          mensajeController.text,
          user.uid,
          selectedUser ?? '',
        );

        // Esperar a que se carguen los mensajes antes de mostrar la notificación
        List<String> nuevosMensajes = await _cargarMensajes();

        var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          'your_channel_description',
          importance: Importance.max,
          priority: Priority.high,
        );

        var platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        await flutterLocalNotificationsPlugin.show(
          0,
          'Título de la notificación',
          'Cuerpo de la notificación',
          platformChannelSpecifics,
        );

        setState(() {
          mensajes = nuevosMensajes;
        });

        // Limpiar el campo de texto después de enviar el mensaje
        mensajeController.clear();

        // Cerrar el teclado virtual
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      print("Error al mostrar notificación: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones y Mensajes'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedUser,
              hint: const Text('Seleccionar destinatario'),
              onChanged: (value) {
                setState(() {
                  selectedUser = value;
                });
              },
              items: ['Usuario1', 'Usuario2', 'Usuario3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: mensajeController,
              decoration: const InputDecoration(
                labelText: '     Ingrese el mensaje',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (selectedUser != null && mensajeController.text.isNotEmpty) {
                  await _mostrarNotificacion();
                } else {
                  // Muestra un mensaje de error si no se selecciona un usuario o el mensaje está vacío
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Seleccione un destinatario e ingrese un mensaje.'),
                    ),
                  );
                }
              },
              child: const Text('Mostrar Notificación y Cargar Mensajes'),
            ),
            const SizedBox(height: 20),
            if (mensajes.isNotEmpty)
              Text('Mensajes recibidos:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            for (String mensaje in mensajes) Text(mensaje),
          ],
        ),
      ),
    );
  }
}

// Obtener una referencia a la colección de mensajes
CollectionReference mensajes =
    FirebaseFirestore.instance.collection('mensajes');

// Ejemplo de cómo agregar un mensaje a Firestore
Future<void> agregarMensaje(
    String contenido, String idEmisor, String idReceptor) {
  return mensajes.add({
    'contenido': contenido,
    'id_emisor': idEmisor,
    'id_receptor': idReceptor,
    'leido': false,
    'fecha': FieldValue.serverTimestamp(),
  });
}
