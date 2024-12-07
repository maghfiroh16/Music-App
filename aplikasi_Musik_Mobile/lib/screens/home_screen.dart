import 'package:auahmobile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:auahmobile/services/spotify_service.dart';
import 'package:auahmobile/screens/album_detail_screen.dart';
import 'package:auahmobile/screens/search_screen.dart';
import 'package:auahmobile/screens/favorites_screen.dart'; // Import halaman Favorit

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;  // Menyimpan halaman yang aktif
  late SpotifyService _spotifyService;  // Menggunakan SpotifyService untuk mengambil data

  @override
  void initState() {
    super.initState();
    _spotifyService = SpotifyService();  // Inisialisasi SpotifyService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),  // Body dinamis berdasarkan index yang aktif
      bottomNavigationBar: _buildBottomNavigationBar(),  // Membuat bottom navigation bar
    );
  }

  // Menentukan body dari halaman berdasarkan index yang aktif
  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _homePage();
      case 1:
        return SearchScreen();  // Halaman pencarian
      case 2:
        return ProfilePage();  // Halaman profil
      case 3:
        return FavoritesScreen();  // Halaman musik favorit
      default:
        return _homePage();  // Default ke halaman utama
    }
  }

  // Membuat tampilan halaman utama dengan daftar album dan lagu random
  Widget _homePage() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Welcome to JoMusic",
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Nikmati pengalaman musik tanpa batas. Jelajahi lagu, album, dan artis favoritmu dengan mudah melalui tombol navigasi di bawah.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
          _buildSectionTitle("New Albums"),
          _buildNewAlbums(),
          SizedBox(height: 30),  // Menambahkan jarak sebelum bagian random tracks
          _buildSectionTitle("Random Tracks"),
          _buildAlbumTracks(),  // Memanggil bagian random tracks
        ],
      ),
    );
  }

  // Membuat tampilan untuk judul section
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // Menampilkan album terbaru
  Widget _buildNewAlbums() {
    return FutureBuilder<List<dynamic>>(
      future: _spotifyService.fetchNewReleases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final albums = snapshot.data!;
          return SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AlbumDetailScreen(album: album),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black.withOpacity(0.3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(album['images'][0]['url']),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                color: Colors.black.withOpacity(0),
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      album['name'],
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      album['artists'][0]['name'],
                                      style: TextStyle(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(child: Text('No data available.'));
        }
      },
    );
  }

  // Menampilkan track random dari album tertentu
  Widget _buildAlbumTracks() {
    return FutureBuilder<List<dynamic>>(
      future: _spotifyService.fetchTracksFromAlbum('4aawyAB9vmqN3uQ7FjRGTy'),  // Mengambil track dari album dengan ID tertentu
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final tracks = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.3),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      leading: Image.network(
                        track['album']['images'][0]['url'], // Gambar album
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        track['name'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        track['artists'][0]['name'],
                        style: TextStyle(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Center(child: Text('No tracks available.'));
        }
      },
    );
  }

  // Membuat bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF0A071E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            offset: Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavigationButton(
            icon: Icons.home,
            onTap: () => _changeScreen(0),
            isActive: _currentIndex == 0,
          ),
          _buildNavigationButton(
            icon: Icons.search,
            onTap: () => _changeScreen(1),
            isActive: _currentIndex == 1,
          ),
          _buildNavigationButton(
            icon: Icons.person,
            onTap: () => _changeScreen(2),
            isActive: _currentIndex == 2,
          ),
          _buildNavigationButton(
            icon: Icons.favorite, // Ikon favorit
            onTap: () => _changeScreen(3),
            isActive: _currentIndex == 3, // Status aktif untuk halaman favorit
          ),
        ],
      ),
    );
  }

  // Fungsi untuk tombol navigasi
  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 30,
        color: isActive ? Colors.white : Colors.grey,
      ),
    );
  }

  // Fungsi untuk mengubah halaman
  void _changeScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
