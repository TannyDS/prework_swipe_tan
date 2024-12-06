import 'dart:convert';
import 'tabbar_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _fromKey = GlobalKey<FormState>();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final url = Uri.parse('https://go-basic.onrender.com/login');
    final header = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'user': _usernameController.text,
      'password': _passwordController.text,
    });

    final response = await http.post(url, headers: header, body: body);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      _showSnackbar(jsonResponse['message']);
      _navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (context) => const TabbarPage()));
    } else if (response.statusCode == 401) {
      final jsonResponse = jsonDecode(response.body);
      _showSnackbar(jsonResponse['message']);
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color.fromARGB(233, 249, 191, 255), // First shade (center)
              Color.fromARGB(233, 252, 248, 173), // Second shade (middle)
              Color.fromARGB(255, 195, 236, 233),
              Color.fromARGB(255, 234, 155, 213),
            ],
            center: Alignment.topLeft,
            radius: 1.5,
            stops: [0.0, 0.5, 1.0, 1.5],
          ),
        ),
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (setting) {
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                backgroundColor: Colors
                    .transparent, // Make the Scaffold background transparent
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _fromKey,
                          child: Column(
                            children: [
                              Image.asset(
                                'images/todoicon.png',
                                width: 250,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      style:
                                          const TextStyle(fontFamily: 'neon'),
                                      controller: _usernameController,
                                      decoration: const InputDecoration(
                                          labelText: "Username",
                                          labelStyle:
                                              TextStyle(fontFamily: 'neon')),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your username';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                          labelText: "Password",
                                          labelStyle:
                                              TextStyle(fontFamily: 'neon')),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 24,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        if (_fromKey.currentState!.validate()) {
                                          _login();
                                        }
                                      },
                                      child: const Text(
                                        'Login',
                                        style: TextStyle(
                                            fontFamily: 'neon',
                                            fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
