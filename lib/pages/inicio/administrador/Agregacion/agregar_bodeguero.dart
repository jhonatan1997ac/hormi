import 'dart:io';
import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        // Define el esquema de colores principal para la aplicación
        primaryColor: Color(0xFF050A30), // Azul oscuro
        hintColor: Colors.amber, // Puedes cambiar esto a un color llamativo
        scaffoldBackgroundColor:
            const Color.fromARGB(255, 173, 164, 80), // Fondo azul oscuro
        appBarTheme: const AppBarTheme(
          backgroundColor:
              Color.fromARGB(144, 5, 10, 48), // Barra de aplicación azul oscuro
        ),
        iconTheme: const IconThemeData(color: Colors.white), // Color del icono
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Color del texto
          bodyMedium: TextStyle(color: Colors.white), // Color del texto
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AgregarBodeguero(),
        '/bodeguero': (context) =>
            const Bodeguero(), // Agregada la ruta para Bodeguero
      },
    ),
  );
}

class AgregarBodeguero extends StatefulWidget {
  const AgregarBodeguero({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AgregarBodegueroState createState() => _AgregarBodegueroState();
}

class _AgregarBodegueroState extends State<AgregarBodeguero> {
  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpassController = TextEditingController();
  final TextEditingController name = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  var options = ['bodeguero'];

  var rool = "bodeguero";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/bodeguero');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/bodeguero');
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            "REGISTRAR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const Text(
                            "NUEVO BODEGUERO ",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Correo',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "El correo electrónico no puede estar vacío.";
                              }
                              if (!RegExp(
                                      "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                  .hasMatch(value)) {
                                return ("Por favor introduzca una dirección de correo electrónico válida");
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {},
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: _isObscure,
                            controller: passwordController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(_isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  }),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Contraseña',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(
                                  r'^.{6,15}$'); // Modificado a 15 caracteres
                              if (value!.isEmpty) {
                                return "La contraseña no puede estar vacía";
                              }
                              if (!regex.hasMatch(value)) {
                                return "Por favor, ingrese una contraseña válida de 6 a 15 caracteres";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            obscureText: _isObscure2,
                            controller: confirmpassController,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                  icon: Icon(_isObscure2
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure2 = !_isObscure2;
                                    });
                                  }),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'confirmar Contraseña',
                              enabled: true,
                              contentPadding: const EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 15.0),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            validator: (value) {
                              if (confirmpassController.text !=
                                  passwordController.text) {
                                return "La contraseña no coincidió";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {},
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          MaterialButton(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20.0),
                              ),
                            ),
                            elevation: 5.0,
                            height: 40,
                            onPressed: () {
                              setState(() {
                                showProgress = true;
                              });
                              signUp(emailController.text,
                                  passwordController.text, rool);
                            },
                            color: Colors.white,
                            child: const Text(
                              "Registro",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password, String rool) async {
    const CircularProgressIndicator();
    if (_formkey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        postDetailsToFirestore(email, rool);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/bodeguero');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error de registro'),
                content: const Text(
                    'El correo electrónico ya está en uso. Por favor, utiliza otro correo electrónico.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aceptar'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print(e);
      }
    }
  }

  postDetailsToFirestore(String email, String rool) async {
    // ignore: unused_local_variable
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    var user = _auth.currentUser;
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({'email': emailController.text, 'rool': rool});
  }
}
