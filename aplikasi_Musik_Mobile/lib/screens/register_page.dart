import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/users'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": _emailController.text,
        "password": _passwordController.text,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User registered successfully!")));
      Navigator.pop(context); // Kembali ke halaman login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to register user")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register',style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF0A071E),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
