import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MusicDetailScreen extends StatefulWidget {
  final dynamic track;  // Data track yang dikirim dari album atau pencarian

  MusicDetailScreen({required this.track});

  @override
  _MusicDetailScreenState createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isFavorited = false; // Menandakan apakah musik ini sudah disukai
  late String userId;  // ID Pengguna (seharusnya datang dari login)

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _checkIfFavorited();  // Cek apakah musik sudah disukai sebelumnya
    userId = "d016"; // Hardcoded ID Pengguna, bisa diganti dengan ID login pengguna
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  // Fungsi untuk mengecek apakah musik sudah disukai
  _checkIfFavorited() async {
    final prefs = await SharedPreferences.getInstance();
    final String trackId = widget.track['id'].toString();
    final bool isFavorited = prefs.getBool(trackId) ?? false;
    setState(() {
      _isFavorited = isFavorited;
    });
  }

  // Fungsi untuk menambahkan/menghapus musik dari favorit
  _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final String trackId = widget.track['id'].toString();

    if (_isFavorited) {
      await prefs.remove(trackId);  // Hapus dari favorit
      _removeFavoriteFromServer(trackId);
    } else {
      await prefs.setBool(trackId, true);  // Tambahkan ke favorit
      _addFavoriteToServer(trackId);
    }

    setState(() {
      _isFavorited = !_isFavorited;  // Perbarui status favorit
    });
  }

  // Fungsi untuk menambahkan musik ke favorit di JSON Server
  _addFavoriteToServer(String trackId) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/favorites'),  // Ganti dengan URL JSON Server Anda
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'userId': userId,
        'trackId': trackId,
        'name': widget.track['name'],
        'artist': widget.track['artists'][0]['name'],
        'album': widget.track['album']['name'],
        'image': widget.track['images'][0]['url'],
        'preview_url': widget.track['preview_url'],
      }),
    );

    if (response.statusCode == 201) {
      print('Music added to favorites in the server');
    } else {
      print('Failed to add music to favorites in the server');
    }
  }

  // Fungsi untuk menghapus favorit dari JSON Server
  _removeFavoriteFromServer(String trackId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/favorites/$trackId'), // Ganti dengan URL JSON Server Anda
    );

    if (response.statusCode == 200) {
      print('Music removed from favorites in the server');
    } else {
      print('Failed to remove music from favorites in the server');
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = widget.track;
    final trackName = track['name'] ?? 'Unknown Track';
    final artistName = track['artists']?.isNotEmpty == true
        ? track['artists'][0]['name']
        : 'Unknown Artist';
    final albumName = track['album']?['name'] ?? 'Unknown Album';
    final albumImage = track?['images']?.isNotEmpty == true
        ? track['images'][0]['url']
        : 'https://via.placeholder.com/300x300.png?text=No+Image';
    final audioUrl = track['preview_url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(trackName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF0A071E),
        elevation: 0, 
      ),
      body: SingleChildScrollView(  // Membuat tampilan dapat digulir
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,  // Centering entire column
            children: [
              // Gambar album dengan radius
              ClipRRect(
                borderRadius: BorderRadius.circular(16),  // Mengatur border radius jika diperlukan
                child: CachedNetworkImage(
                  imageUrl: albumImage,
                  height: 150,  // Set height yang diinginkan
                  width: 150,   // Set width yang sama agar gambar berbentuk persegi
                  fit: BoxFit.cover,  // Atur gambar agar mengisi area persegi dengan proporsional
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Nama track, artist, dan album di tengah
              Text(
                trackName,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,  // Center the text
              ),
              SizedBox(height: 10),
              Text(
                'Artist: $artistName',
                style: TextStyle(fontSize: 18, color: Colors.grey[300]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Album: $albumName',
                style: TextStyle(fontSize: 18, color: Colors.grey[300]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              // Tombol Play/Pause yang menarik
              GestureDetector(
                onTap: () async {
                  if (_isPlaying) {
                    await _audioPlayer.stop();
                  } else {
                    if (audioUrl.isNotEmpty) {
                      await _audioPlayer.play(audioUrl);
                    }
                  }

                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: _isPlaying ? Color(0xFF1DB954) : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _isPlaying ? Colors.black : Colors.green,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Tombol untuk menambahkan musik ke favorit
              Center(
                child: ElevatedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Colors.red : Colors.white,
                  ),
                  label: Text(
                    _isFavorited ? 'Remove from Favorites' : 'Add to Favorites',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF0A071E)),
                    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 15, horizontal: 25)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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
