import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _selectedUserRole = 'Vendedor'; // Valor predeterminado

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
            const SizedBox(height: 40), // Agregamos un espacio adicional
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
                // Agregar un campo para seleccionar el tipo de usuario
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

  Future<void> _iniciarSesion(BuildContext context) async {
    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      setState(() {
        _isLoggedIn = true;
      });
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (kDebugMode) {
        print('Error de inicio de sesión: $e');
      }

      String errorMessage =
          'Error al iniciar sesión. Verifica tus credenciales.';

      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          errorMessage =
              'Usuario no encontrado. Regístrate para crear una cuenta.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Contraseña incorrecta. Inténtalo de nuevo.';
        }
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(seconds: 3),
        ),
      );
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
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error al cerrar sesión: $e');
        print('StackTrace: $stackTrace');
      }
    }
  }

  Future<void> _crearCuenta(BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Obtener el UID del usuario recién creado
        // ignore: unused_local_variable
        String uid = userCredential.user!.uid;

        // Asignar el rol según la selección del usuario
        if (_selectedUserRole == 'Vendedor') {
          // Lógica para asignar el rol de vendedor al usuario
          // Puedes guardar esta información en Firestore o en otra base de datos
          // dependiendo de tu implementación.
        } else if (_selectedUserRole == 'Administrador') {
          // Lógica para asignar el rol de administrador al usuario
          // Puedes guardar esta información en Firestore o en otra base de datos
          // dependiendo de tu implementación.
        }

        setState(() {
          _isLoggedIn = true;
        });

        // Mostrar un SnackBar de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta creada con éxito'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error al crear cuenta: $e');
        print('StackTrace: $stackTrace');
      }

      // Mostrar un SnackBar de error
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear cuenta. Intenta nuevamente.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
