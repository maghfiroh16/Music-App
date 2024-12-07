import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String clientId = 'bc8a1eca71a544b9bef3b75a66203aa2';
  final String clientSecret = '1baecfbd32cf4275a8337f120126a667';
  String? _accessToken;

  // Fungsi untuk mendapatkan access token
  Future<void> authenticate() async {
    final url = Uri.parse('https://accounts.spotify.com/api/token');
    final response = await http.post(url,
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'grant_type': 'client_credentials'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  // Fungsi untuk mengambil album terbaru
  Future<List<dynamic>> fetchNewReleases() async {
    await _ensureAuthenticated();
    final url = Uri.parse('https://api.spotify.com/v1/browse/new-releases');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_accessToken',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['albums']['items'] ?? []; // Mengembalikan list kosong jika tidak ada album
    } else {
      throw Exception('Failed to load new releases');
    }
  }

  // Fungsi untuk mendapatkan lagu-lagu dalam album
  Future<List<dynamic>> fetchTracksInAlbum(String albumId) async {
    await _ensureAuthenticated();
    final url = Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_accessToken',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] ?? []; // Mengembalikan list kosong jika tidak ada track
    } else {
      throw Exception('Failed to load tracks');
    }
  }

  // Fungsi untuk mengambil semua track dari album
  Future<List<dynamic>> fetchAlbumTracks(String albumId) async {
    await _ensureAuthenticated();
    List<dynamic> allTracks = [];
    String? nextUrl;

    do {
      final url = nextUrl ?? 'https://api.spotify.com/v1/albums/$albumId/tracks';
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $_accessToken',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        allTracks.addAll(data['items']);
        nextUrl = data['next'];
      } else {
        throw Exception('Failed to load album tracks');
      }
    } while (nextUrl != null); // Loop hingga tidak ada lagi halaman berikutnya

    return allTracks;
  }

  // Fungsi untuk melakukan pencarian
Future<List<dynamic>> search(String query) async {
  await _ensureAuthenticated();
  final url = 'https://api.spotify.com/v1/search';
  final response = await http.get(
    Uri.parse('$url?q=$query&type=album,track,artist&limit=10'),
    headers: {'Authorization': 'Bearer $_accessToken'},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<dynamic> results = [];

    if (data['albums']['items'] != null) {
      results.addAll(data['albums']['items']);
    }
    if (data['tracks']['items'] != null) {
      // Menambahkan track ke hasil dan memeriksa preview_url
      final tracks = data['tracks']['items'];
      for (var track in tracks) {
        if (track['preview_url'] != null) {
          track['hasPreview'] = true;  // Menambahkan flag apakah track memiliki preview
        } else {
          track['hasPreview'] = false;
        }
        results.add(track);
      }
    }
    if (data['artists']['items'] != null) {
      results.addAll(data['artists']['items']);
    }

    return results;
  } else {
    throw Exception('Failed to load search results');
  }
}
 Future<List<dynamic>> fetchTracksFromAlbum(String albumId) async {
  final response = await http.get(
    Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks'),
    headers: {
      'Authorization': 'Bearer $_accessToken', // Pastikan token ini valid
    },
  );

  if (response.statusCode == 200) {
    try {
      final data = json.decode(response.body);

      // Memeriksa apakah data['items'] ada dan merupakan list
      if (data['items'] != null && data['items'] is List) {
        return List.from(data['items']); // Mengembalikan daftar track
      } else {
        throw Exception('No tracks found or invalid format');
      }
    } catch (e) {
      throw Exception('Failed to parse tracks: $e');
    }
  } else {
    throw Exception('Failed to load tracks from album: ${response.statusCode}');
  }
}


  // Menjamin token sudah terautentikasi sebelum melakukan request
  Future<void> _ensureAuthenticated() async {
    if (_accessToken == null) {
      await authenticate();
    }
  }
}
