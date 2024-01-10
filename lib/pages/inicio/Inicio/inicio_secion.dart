import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Inicio de Sesión',
      home: Secion(),
    );
  }
}

class Secion extends StatefulWidget {
  const Secion({Key? key});

  @override
  _SecionState createState() => _SecionState();
}

class _SecionState extends State<Secion> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoggedIn = false;
  bool _showPassword = false;
  bool _loading = false;
  String _selectedUserRole = 'Vendedor';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 108, 120, 131),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text(
              'BIENVENIDOS A NUESTRA APLICACIÓN',
              style: TextStyle(fontSize: 25.0, color: Colors.white),
            ),
            const Text(
              'SOMOS HOMIBLOQUE ECUADOR S.A',
              style: TextStyle(fontSize: 25.0, color: Colors.white),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: const Text(
                          'Inicio de Sesión',
                          style: TextStyle(
                              fontSize: 24.0,
                              color: Color.fromARGB(255, 14, 13, 13)),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                            child: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _loading
                                ? null
                                : _isLoggedIn
                                    ? _cerrarSesion
                                    : () async {
                                        await _mostrarFormularioCrearCuenta(
                                            context);
                                      },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 99, 206, 66),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator()
                                : _isLoggedIn
                                    ? const Text('Cerrar Sesión')
                                    : const Text('Crear Cuenta'),
                          ),
                          const SizedBox(width: 2.0),
                          ElevatedButton(
                            onPressed: _loading
                                ? null
                                : () async {
                                    await _iniciarSesion(context);
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 89, 48, 201),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator()
                                : const Text('Iniciar Sesión'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarFormularioCrearCuenta(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Crear Cuenta'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: _selectedUserRole,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedUserRole = value!;
                    });
                  },
                  items: ['Vendedor', 'Administrador']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      await _crearCuenta(context);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Crear Cuenta'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarUsuarioExistente(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Usuario Existente'),
          content: const Text('El usuario ya existe. Por favor, elige otro.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _iniciarSesion(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      setState(() {
        _isLoggedIn = true;
      });

      // Después de iniciar sesión con éxito, redirigir según el rol del usuario
      route();
    } catch (e) {
      // Manejar errores aquí
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      await _auth.signOut();
      setState(() {
        _isLoggedIn = false;
      });
    } catch (e) {
      // Manejar errores aquí
    }
  }

  Future<void> _crearCuenta(BuildContext context) async {
    try {
      bool nombreUsuarioExistente =
          await _verificarNombreUsuario(_emailController.text.trim());

      if (nombreUsuarioExistente) {
        // ignore: use_build_context_synchronously
        await _mostrarUsuarioExistente(context);
        return;
      }

      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Después de crear la cuenta con éxito, redirigir según el rol seleccionado
      route();
    } catch (e) {
      // Manejar errores aquí
    }
  }

  Future<bool> _verificarNombreUsuario(String nombreUsuario) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('usuarios')
        .where('nombreUsuario', isEqualTo: nombreUsuario)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  // Función para redirigir según el rol del usuario
  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    // ignore: unused_local_variable
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('rool') == "Teacher") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Teacher(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Student(),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print('Document does not exist on the database');
        }
      }
    });
  }
}

class Student extends StatelessWidget {
  const Student({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Screen'),
      ),
      body: const Center(
        child: Text('Content for the Student'),
      ),
    );
  }
}

class Teacher extends StatelessWidget {
  const Teacher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Screen'),
      ),
      body: const Center(
        child: Text('Content for the Teacher'),
      ),
    );
  }
}
