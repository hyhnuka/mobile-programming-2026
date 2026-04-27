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

## Interface
* Login & Registrasi
<p align="center">
  <img src="https://github.com/user-attachments/assets/4fc6370d-8621-47ba-ab48-f459be03406f" width="20%"/>
  <img src="https://github.com/user-attachments/assets/88fdf45e-04c5-434d-bc5d-9e3ffafe2f84" width="20%"/>
</p>
* Dashboard & Insight Admin
<p align="center">
  <img width="789" height="1600" alt="WhatsApp Image 2026-04-27 at 1 45 12 PM" src="https://github.com/user-attachments/assets/073dd41e-f6aa-45c7-85db-e49e7bdf1991" />
  <img width="792" height="1600" alt="WhatsApp Image 2026-04-27 at 1 45 12 PM (1)" src="https://github.com/user-attachments/assets/3ee9bff5-4618-4d13-aa61-b0a1dbf9abb7" />
  <img width="788" height="1600" alt="WhatsApp Image 2026-04-27 at 1 45 12 PM (2)" src="https://github.com/user-attachments/assets/8877f22f-3df3-46fb-9ce0-a4a5596de7da" />
</p>
* Dashboard & Insight Member
<p align="center">
  <img width="790" height="1600" alt="WhatsApp Image 2026-04-27 at 1 43 24 PM" src="https://github.com/user-attachments/assets/c3a46c83-423e-42c3-bfaf-f5d2cffc15d6" />
  <img width="791" height="1600" alt="WhatsApp Image 2026-04-27 at 1 43 24 PM (2)" src="https://github.com/user-attachments/assets/5f7fbc8c-be55-4660-9e3e-9bb77d77bad5" />
  <img width="790" height="1599" alt="WhatsApp Image 2026-04-27 at 1 43 23 PM" src="https://github.com/user-attachments/assets/dbeb5391-d385-4ae2-8c90-345584c28ec4" />
</p>

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
