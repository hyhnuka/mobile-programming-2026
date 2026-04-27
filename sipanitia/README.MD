# SiPanitia - Event Job Tracker

**SiPanitia** adalah aplikasi manajemen tugas kepanitiaan event yang dirancang untuk membantu koordinasi antara Admin (Ketua/Koordinator) dan Member (Staf/Anggota). Aplikasi ini memungkinkan pembagian tugas yang efisien, pelacakan progres secara real-time, dan sistem notifikasi lokal untuk memastikan setiap tenggat waktu terpenuhi.

Aplikasi ini dibangun menggunakan **Flutter** dengan integrasi **Firebase** untuk autentikasi dan **SQLite** untuk penyimpanan data relasional lokal.

## Fitur 

* **Manajemen Tugas (CRUD):** Admin dapat membuat, membaca, memperbarui, dan menghapus tugas kepanitiaan melalui database relasional lokal (SQLite).
* **Autentikasi Firebase:** Sistem login dan registrasi yang aman menggunakan Firebase Authentication dengan pembagian role (Admin & Member).
* **Penyimpanan Cloud (Firestore):** Data profil pengguna dan pembagian divisi disimpan secara sinkron di Cloud Firestore.
* **Notifikasi Lokal:** Pemberian peringatan otomatis kepada Member saat ada penugasan baru atau perubahan deadline dari Admin.
* **Integrasi Kamera (Smartphone Resource):** Member dapat mengambil foto secara langsung sebagai bukti penyelesaian tugas.
* **Statistik & Insight:** Halaman dashboard visual yang menampilkan persentase progres divisi, total tugas, dan jumlah PIC aktif.

## Tech Stack

* **Framework:** [Flutter](https://flutter.dev/)
* **Database Lokal:** SQLite (sqflite)
* **Backend & Auth:** Firebase (Auth & Firestore)
* **Icons:** Iconsax
* **Resource:** Image Picker (Camera)

## How to Run

Sebelum menjalankan proyek ini, pastikan Anda telah menginstal:
* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Android Studio](https://developer.android.com/studio) atau VS Code
* Proyek [Firebase](https://console.firebase.google.com/) yang sudah terkonfigurasi

## Instalasi

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/hyhnuka/mobile-programming-2026.git
    cd mobile-programming-2026/sipanitia
    ```

2.  **Instal dependensi:**
    ```bash
    flutter pub get
    ```

3.  **Konfigurasi Firebase:**
    * Letakkan file `google-services.json` Anda di folder `android/app/`.
    * Pastikan `firebase_options.dart` sudah sesuai dengan konfigurasi proyek Anda.

4.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

*Proyek ini dikembangkan untuk memenuhi tugas mata kuliah Pemrograman Perangkat Bergerak (PPB) 2026.*
README.MD
