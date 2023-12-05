import 'package:apphormi/servicio/firebase_usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a hormibloque ecuador S.A'),
      ),
      body: FutureBuilder(
        future: getUsuario(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Text('No hay datos disponibles.');
          } else {
            // Crear una lista de tarjetas (Card) para cada nombre
            List<Widget> cards = [];
            for (var index = 0; index < snapshot.data!.length; index++) {
              var nombre =
                  snapshot.data?[index]['nombre'] ?? 'Nombre no disponible';
              cards.add(
                Card(
                  child: Dismissible(
                    onDismissed: (direction) async {
                      await deleteUsuario(snapshot.data?[index]['uid']);
                    },
                    confirmDismiss: (direction) async {
                      bool result = false;
                      result = await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(
                                  "¿Esta seguro de querer eliminar a ${snapshot.data?[index]['nombre']}?"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      return Navigator.pop(
                                        context,
                                        false,
                                      );
                                    },
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.red),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      return Navigator.pop(
                                        context,
                                        true,
                                      );
                                    },
                                    child: const Text("Si, estoy seguro"))
                              ],
                            );
                          });
                      return result;
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                    direction: DismissDirection.endToStart,
                    key: Key(
                        snapshot.data?[index]['uid']), // deslizar para eliminar
                    child: ListTile(
                      title: Text(nombre),
                      onTap: () {
                        // Navegar a otra pantalla cuando se toca el texto
                        Navigator.pushNamed(context, '/edit', arguments: {
                          "nombre": snapshot.data?[index]['nombre'],
                          "uid": snapshot.data?[index]['uid'],
                        });
                      },
                    ),
                  ),
                ),
              );
            }

            // Usar un ListView para mostrar las tarjetas en orden
            return ListView(
              children: cards,
            );
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/agg');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List usuarios = [];

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  void getUsers() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection("usuario");
    QuerySnapshot users = await collectionReference.get();
    if (users.docs.isNotEmpty) {
      for (var doc in users.docs) {
        if (kDebugMode) {
          print(doc.data());
          setState(() {
            usuarios.add(doc.data());
          });
        }
      }
    }
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Has presionado el botón tantas veces:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Users: $usuarios',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
