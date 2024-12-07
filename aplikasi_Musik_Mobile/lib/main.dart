import 'dart:convert';
import 'package:auahmobile/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:auahmobile/screens/register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF0A071E),
        hintColor: Color(0xFF9C27B0),
        scaffoldBackgroundColor: Color(0xFF0A071E),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Fungsi untuk login
  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // URL endpoint untuk login di JSON Server
    final response = await http.get(
      Uri.parse('http://localhost:3000/users?email=$email&password=$password'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data.isNotEmpty) {
        // Jika user ditemukan, navigasi ke HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid email or password")),
        );
      }
    } else {
      // Error request
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load data")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Color(0xFF0A071E),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF1E1B29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF1E1B29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login',  style: TextStyle(
      color: Colors.white, // Menambahkan warna putih pada teks
    ),
  ),
              
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9C27B0),
                padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text(
                "Don't have an account? Register",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Fungsi untuk registrasi
  Future<void> _register() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    // URL endpoint untuk registrasi di JSON Server
    final response = await http.post(
      Uri.parse('http://localhost:3000/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      // Jika registrasi sukses
      Navigator.pop(context); // Kembali ke halaman login setelah registrasi
    } else {
      // Jika registrasi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Color(0xFF0A071E),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF1E1B29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF1E1B29),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
ElevatedButton(
  onPressed: _register,
  child: Text(
    'Register',
    style: TextStyle(
      color: Colors.white, // Menambahkan warna putih pada teks
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF9C27B0),
    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
)

          ],
        ),
      ),
    );
  }
}
