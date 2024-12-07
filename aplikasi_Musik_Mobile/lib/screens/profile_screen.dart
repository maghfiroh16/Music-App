import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variabel untuk menyimpan data pengguna
  Map<String, dynamic>? user;

  // Fungsi untuk mengambil data dari JSON Server
  Future<void> fetchUserData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Ambil data pengguna pertama dari JSON (atau sesuaikan dengan ID atau logika lain)
      setState(() {
        user = data.isNotEmpty ? data[0] : null;
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();  // Ambil data saat halaman dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFF1E1B29),
      ),
      body: user == null
          ? Center(child: CircularProgressIndicator())  // Menunggu data
          : Center(  // Memusatkan seluruh konten di tengah layar
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,  // Memusatkan elemen secara vertikal
                  crossAxisAlignment: CrossAxisAlignment.center,  // Memusatkan elemen secara horizontal
                  children: [
                    // Gambar profil dengan gambar yang disesuaikan
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage(
                          'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'), // Gambar profil dari URL yang Anda berikan
                    ),
                    SizedBox(height: 20),

                    // Nama pengguna (email atau ID)
                    Text(
                      user!['email'] != '' ? user!['email'] : 'No Email Provided',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Menampilkan ID pengguna
                    Text(
                      'ID: ${user!['id']}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Tombol untuk mengedit profil
                    ElevatedButton(
                      onPressed: () {
                        // Fungsi untuk mengedit profil
                      },
                      child: Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, color: Colors.white
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

