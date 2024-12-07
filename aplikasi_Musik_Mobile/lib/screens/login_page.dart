import 'dart:convert';
import 'package:auahmobile/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));
    if (response.statusCode == 200) {
      List users = jsonDecode(response.body);
      final user = users.firstWhere(
        (u) => u['email'] == _emailController.text && u['password'] == _passwordController.text,
        orElse: () => null,
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Invalid email or password")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch users")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',style: TextStyle(color: Colors.white),),
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
              onPressed: _login,
              child: Text('Login'),
              
            ),
          ],
        ),
      ),
    );
  }
}
