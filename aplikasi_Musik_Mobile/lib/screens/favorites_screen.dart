import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late List<dynamic> favoriteTracks = [];  // List of favorite tracks
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _fetchFavorites();
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.dispose();
  }

  // Fetching favorite tracks from JSON Server
  _fetchFavorites() async {
    final response = await http.get(Uri.parse('http://localhost:3000/favorites'));  // Ganti dengan URL JSON Server Anda

    if (response.statusCode == 200) {
      setState(() {
        favoriteTracks = json.decode(response.body);
      });
    } else {
      print('Failed to load favorite tracks');
    }
  }

  // Playing or pausing the selected track
  _togglePlay(String audioUrl) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    } else {
      if (audioUrl.isNotEmpty) {
        await _audioPlayer.play(audioUrl as Source);
      }
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  title: Text(
    'Favorites Music',
    style: TextStyle(color: Colors.white),  // Ubah warna teks menjadi hitam
  ),
  backgroundColor: Color(0xFF0A071E),  // Latar belakang putih
),

      body: favoriteTracks.isEmpty
          ? Center(child: CircularProgressIndicator())  // Loading indicator if the list is empty
          : ListView.builder(
              itemCount: favoriteTracks.length,
              itemBuilder: (context, index) {
                final track = favoriteTracks[index];
                final trackName = track['name'] ?? 'Unknown Track';
                final artistName = track['artist'] ?? 'Unknown Artist';
                final albumName = track['album'] ?? 'Unknown Album';
                final albumImage = track['image'] ?? 'https://via.placeholder.com/300x300.png?text=No+Image';
                final audioUrl = track['preview_url'] ?? '';

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: albumImage,
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                  title: Text(trackName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('$artistName • $albumName', style: TextStyle(color: Colors.white),),
                  trailing: IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () => _togglePlay(audioUrl),
                  ),
                );
              },
            ),
    );
  }
}
