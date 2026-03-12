# Flutter Widget Layout & Stateful Counter

<img width="425" height="1016" alt="image" src="https://github.com/user-attachments/assets/ad0a34ee-eecc-483a-9aa1-ab0faf0d8db3" />

## Deskripsi

Project ini merupakan aplikasi Flutter sederhana yang menampilkan penggunaan beberapa widget dasar seperti **Column, Row, Container, Image, dan StatefulWidget**.
Aplikasi ini juga menampilkan contoh penggunaan **MediaQuery**, **AspectRatio**, serta implementasi **state management sederhana menggunakan StatefulWidget** untuk membuat fitur counter.

Aplikasi terdiri dari beberapa bagian utama:

* Gambar yang diambil dari internet
* Teks deskripsi gambar
* Menu kategori dengan ikon
* Counter interaktif yang dapat bertambah ketika tombol ditekan

---

# Struktur Widget

## 1. MyApp

`MyApp` merupakan root widget dari aplikasi yang mengatur tema aplikasi dan halaman utama.

Fitur:

* Menggunakan `MaterialApp`
* Mengatur tema menggunakan `ColorScheme`
* Mengarahkan halaman utama ke `RowColumnPage`

---

## 2. RowColumnPage

Widget ini merupakan halaman utama aplikasi yang menggunakan **StatelessWidget**.

Komponen yang digunakan:

* `Scaffold`
* `AppBar`
* `Column`
* `Row`
* `Container`
* `AspectRatio`
* `MediaQuery`

### Layout Halaman

Halaman terdiri dari beberapa bagian:

1. **Image Section**

   * Menampilkan gambar dari internet menggunakan `Image.network`
   * Dibungkus dengan `AspectRatio` agar proporsinya tetap

2. **Text Section**

   * Container berwarna pink yang menampilkan teks:

   ```
   What image is that
   ```

3. **Icon Menu Section**
   Menggunakan `Row` yang berisi tiga `Column` dengan ikon:

   * Food
   * Scenery
   * People

4. **Counter Section**
   Menampilkan widget `CounterCard` yang memiliki fitur counter interaktif.

---

# Stateful Widget

## CounterCard

`CounterCard` adalah widget yang menggunakan **StatefulWidget** karena memiliki data yang dapat berubah.

### State

```dart
int _counter = 0;
```

### Fungsi Increment

```dart
void _incrementCounter() {
  setState(() {
    _counter++;
  });
}
```

Ketika tombol `+` ditekan, fungsi ini akan:

1. Menambah nilai counter
2. Memanggil `setState()`
3. UI akan otomatis diperbarui

---

# Konsep Flutter yang Digunakan

Beberapa konsep Flutter yang dipelajari pada project ini:

### 1. Layout Widget

* Column
* Row
* Container

### 2. Responsive Layout

Menggunakan `MediaQuery` untuk mendapatkan ukuran layar perangkat.

### 3. AspectRatio

Digunakan untuk menjaga rasio gambar agar tetap proporsional.

### 4. StatefulWidget

Digunakan untuk membuat komponen dengan **state yang bisa berubah** seperti counter.


```

