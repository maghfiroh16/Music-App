import 'package:flutter/material.dart';
import 'package:auahmobile/services/spotify_service.dart';
import 'music_detail_screen.dart'; // Import MusicDetailScreen

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final SpotifyService _spotifyService = SpotifyService();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  // Fungsi untuk mencari data
  Future<void> _search() async {
    if (_controller.text.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _spotifyService.search(_controller.text);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Color(0xFF0A071E),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // TextField untuk input pencarian
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Changes position of shadow
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (query) {
                  _search();  // Panggil fungsi pencarian saat teks berubah
                },
                style: TextStyle(fontSize: 16, color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Search for songs, albums, or artists',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Color(0xFF9C27B0)),
                    onPressed: _search,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Menampilkan hasil pencarian
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: _searchResults.isEmpty
                        ? Center(child: Text('No results found', style: TextStyle(color: Colors.white)))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final result = _searchResults[index];
                              String type = result['type'] ?? 'track'; // Default 'track' jika tidak ada jenis yang jelas
                              
                              // Tentukan gambar yang akan ditampilkan berdasarkan jenis result
                              String imageUrl = '';

                              if (type == 'album') {
                                imageUrl = result['images'] != null && result['images'].isNotEmpty
                                    ? result['images'][0]['url']
                                    : 'https://via.placeholder.com/300x300.png?text=No+Image'; // Gambar fallback
                              } else if (type == 'track') {
                                imageUrl = result['album'] != null && result['album']['images'] != null
                                    && result['album']['images'].isNotEmpty
                                    ? result['album']['images'][0]['url']
                                    : 'https://via.placeholder.com/300x300.png?text=No+Image'; // Gambar fallback
                              } else if (type == 'artist') {
                                // Biasanya artist tidak memiliki gambar album, tapi jika ada gambar, ambil dari result
                                imageUrl = result['images'] != null && result['images'].isNotEmpty
                                    ? result['images'][0]['url']
                                    : 'https://via.placeholder.com/300x300.png?text=No+Image'; // Gambar fallback
                              }

                              // Tampilkan item berdasarkan tipe
                              switch (type) {
                                case 'album':
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(15),
                                      title: Text(result['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(result['artists'][0]['name']),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          imageUrl,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      onTap: () {
                                        // Navigasi ke halaman detail album
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MusicDetailScreen(track: result),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                case 'track':
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(15),
                                      title: Text(result['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(result['artists'][0]['name']),
                                      leading: Icon(Icons.music_note, color: Color(0xFF9C27B0)),
                                      onTap: () {
                                        // Logika untuk navigasi track jika diperlukan
                                      },
                                    ),
                                  );
                                case 'artist':
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 5,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(15),
                                      title: Text(result['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text("Artist"),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          imageUrl,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      onTap: () {
                                        // Logika untuk navigasi artist jika diperlukan
                                      },
                                    ),
                                  );
                                default:
                                  return Container();
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
