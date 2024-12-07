import 'package:flutter/material.dart';
import 'package:auahmobile/services/spotify_service.dart';
import 'package:auahmobile/screens/music_detail_screen.dart'; // Import halaman MusicDetailScreen

class AlbumDetailScreen extends StatefulWidget {
  final dynamic album;

  AlbumDetailScreen({required this.album});

  @override
  _AlbumDetailScreenState createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  late SpotifyService _spotifyService;
  late Future<List<dynamic>> _tracksFuture;

  @override
  void initState() {
    super.initState();
    _spotifyService = SpotifyService();
    _tracksFuture = _spotifyService.fetchTracksInAlbum(widget.album['id']);
    print("Album Data: ${widget.album}");  // Debugging album data
  }

  @override
  Widget build(BuildContext context) {
    // Cek apakah album memiliki gambar dan data yang valid
    final albumImage = widget.album['images']?.isNotEmpty == true
        ? widget.album['images'][0]['url']
        : null;
    final albumName = widget.album['name'] ?? 'No Name';
    final artistName = widget.album['artists']?.isNotEmpty == true
        ? widget.album['artists'][0]['name']
        : 'Unknown Artist';

    return Scaffold(
      appBar: AppBar(
        title: Text(albumName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF0A071E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar album dengan desain lebih besar dan border radius
            albumImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      albumImage,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[700],
                    child: Icon(Icons.image, color: Colors.white),
                  ),
            SizedBox(height: 20),
            // Nama album dan artis
            Text(
              albumName,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              artistName,
              style: TextStyle(fontSize: 18, color: Colors.grey[300]),
            ),
            SizedBox(height: 20),
            // Track List
            Text(
              'Tracks:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
            ),
            SizedBox(height: 10),
            // Menampilkan tracks dengan FutureBuilder
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _tracksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  } else if (snapshot.hasData) {
                    final tracks = snapshot.data!;
                    return ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          color: Colors.grey[800],
                          child: ListTile(
                            title: Text(
                              track['name'],
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              track['artists'][0]['name'],
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            leading: Icon(Icons.music_note, color: Colors.white),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MusicDetailScreen(track: track),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(child: Text('No tracks available.', style: TextStyle(color: Colors.white)));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
