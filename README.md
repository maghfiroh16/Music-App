# JoMusic App
Aplikasi musik mirip Spotify yang memungkinkan pengguna untuk mencari musik, menambahkannya ke favorit, dan mengelola playlist favorit mereka.
## Fitur Utama:
- **Login/Register**: Login Register untuk masuk ke dalam aplikasi.
- **Pencarian Musik**: Mencari lagu berdasarkan nama, artis, atau album.
- **Menambah ke Favorit**: Menambahkan lagu ke daftar favorit.
- **Favorit Musik**: Melihat daftar musik yang telah difavoritkan.
## Persyaratan:
- Node.js dan npm
- json-server (untuk menjalankan database lokal)
- Flutter (untuk aplikasi mobile)
## Instalasi:

1. **Clone repository ini** ke komputer kamu:
   ```bash
   git clone https://github.com/johararifin2902/music-App-Flutter.git
   ```
   ```bash
   cd music-App-Flutter
   ```

2. **Instalasi dependencies:**
   **Flutter**:
   ```bash
   flutter pub get
   ```

   **json-server**:
   ```bash
   npm install -g json-server
   ```

3. **Menjalankan server JSON**:
   Jalankan server json-server untuk mendapatkan data musik dan menyimpan favorit, dan menyimpan data login register:
   ```bash
   json-server --watch db.json --port 3000
   ```

4. **Menjalankan aplikasi Flutter**:
   Setelah server json-server berjalan, jalankan aplikasi Flutter:
   ```bash
   flutter run
   ```

