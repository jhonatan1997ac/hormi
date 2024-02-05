// ignore_for_file: library_private_types_in_public_api

import 'package:apphormi/pages/inicio/bodega/bodeguero.dart';
import 'package:apphormi/pages/inicio/administrador/administrador.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'registrar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../inicio/vendedores/vendedor.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ignore: unused_field
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color: Color.fromARGB(179, 8, 14, 44),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.70,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(12),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "INICIAR SESIÓN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
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
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
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
                          onSaved: (value) {
                            emailController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure3,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                                icon: Icon(_isObscure3
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure3 = !_isObscure3;
                                  });
                                }),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: 'Contraseña',
                            enabled: true,
                            contentPadding: const EdgeInsets.only(
                                left: 14.0, bottom: 8.0, top: 15.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "La contraseña no puede estar vacía";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("por favor ingrese una contraseña válida min. 6 caracteres");
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            passwordController.text = value!;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          elevation: 5.0,
                          height: 40,
                          onPressed: () {
                            setState(() {
                              visible = true;
                            });
                            signIn(
                                emailController.text, passwordController.text);
                          },
                          color: Colors.white,
                          child: const Text(
                            "Acceder",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: visible,
                          child: Container(
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 255, 255, 255),
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 5.0,
                      height: 40,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Register(),
                          ),
                        );
                      },
                      color: Colors.blue[900],
                      child: const Text(
                        "Registrarse ahora ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void route() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (documentSnapshot.exists) {
          String? userRole = documentSnapshot.get('rool');

          if (userRole != null) {
            if (userRole == "vendedor") {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const VendedorHome(),
                ),
              );
            } else if (userRole == "bodeguero") {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const BodegueroHome(),
                ),
              );
            } else {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const Administrador(),
                ),
              );
            }
          } else {
            if (kDebugMode) {
              print('El rol de usuario es nulo');
            }
          }
        } else {
          if (kDebugMode) {
            print('El documento no existe en la base de datos.');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error al recuperar los datos del usuario: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('El usuario es nulo');
      }
    }
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        // ignore: unused_local_variable
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        route();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'Usuario no encontrado') {
          if (kDebugMode) {
            print('Ningún usuario encontrado para ese correo electrónico.');
          }
        } else if (e.code == 'contraseña incorrecta') {
          if (kDebugMode) {
            print('Contraseña incorrecta proporcionada para ese usuario.');
          }
        }
      }
    }
  }
}
