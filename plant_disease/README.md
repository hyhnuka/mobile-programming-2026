# Plant Disease Detector

**Plant Disease Detector** adalah aplikasi berbasis mobile yang dikembangkan menggunakan Flutter untuk mendeteksi penyakit pada tanaman secara *real-time*. Menggunakan integrasi Machine Learning (TensorFlow Lite), aplikasi ini mampu memberikan diagnosa penyakit, penyebab, hingga langkah penanganan yang tepat bagi pengguna.

Penyakit yang dapat dideteksi terbatas sebagai berikut:
- Pepper Bell Bacterial Spot
- Pepper Bell Healthy
- Potato Early Blight
- Potato Healthy
- Potato Late Blight
- Tomato Bacterial Spot
- Tomato Early Blight
- Tomato Healthy
- Tomato Late Blight
- Tomato Leaf Mold
- Tomato Septoria Leaf Spot
- Tomato Spotted Spider Mites
- Tomato Target Spot
- Tomato Mosaic Virus
- Tomato Yellow Leaf Curl Virus


---

## Fitur 

- **AI Image Classification**: Deteksi penyakit tanaman melalui kamera atau galeri menggunakan model TensorFlow Lite.
- **Detailed Diagnosis**: Memberikan informasi mendalam mengenai penyebab penyakit dan langkah penanganan sistematis.
- **History Management**: Menyimpan riwayat deteksi ke dalam database lokal (SQLite) agar pengguna bisa memantau perkembangan tanaman.

---

## User Interface (Screenshots)

Silakan isi link gambar di bawah ini sesuai dengan hasil tangkapan layar aplikasimu:

| Dashboard | Detection Result | Detail View |
| :---: | :---: | :---: | :---: |
| !<img width="590" height="1599" alt="WhatsApp Image 2026-05-10 at 11 26 52 PM" src="https://github.com/user-attachments/assets/57a9192f-61df-4de3-ad73-c2981cc4a4c5" />
 | !<img width="588" height="1600" alt="WhatsApp Image 2026-05-10 at 11 26 53 PM" src="https://github.com/user-attachments/assets/41f1551f-9b95-4b3f-9ef0-5a9768434685" />
 | !<img width="590" height="1600" alt="WhatsApp Image 2026-05-10 at 11 26 53 PM (1)" src="https://github.com/user-attachments/assets/237f81e7-d47b-442a-b046-8bc761dc7674" />
 |

---

## Arsitektur & Teknologi

### 1. Mobile Framework
- **Flutter**: Sebagai kerangka utama pengembangan aplikasi.
- **Animations Package**: Digunakan untuk implementasi *Container Transform* agar transisi antar halaman terasa premium.

### 2. Machine Learning
- **TFLite (tflite_v2)**: Menjalankan inferensi model `.tflite` secara *on-device*.
- **Custom Model**: Model diklasifikasikan ke beberapa label tanaman (Pepper, Potato, Tomato, dll).

### 3. Database & Storage
- **SQLite (sqflite)**: Menyimpan metadata deteksi (label, tanggal, penyebab, path gambar).
- **Path Provider**: Manajemen direktori penyimpanan gambar hasil foto ke dalam folder privat aplikasi.

---

## Struktur Folder

lib/
 ├── main.dart             
 ├── screens/              
 ├── services/             # Database & Classifier AI
 └── widgets/              
assets/
 ├── model_unquant.tflite  # Model AI
 ├── labels.txt            # Label kelas penyakit
 └── explain-label.json    # Database informasi penyakit

---

## Instalasi

1.  **Clone repositori:**
    ```bash
    git clone https://github.com/hyhnuka/mobile-programming-2026.git
    cd mobile-programming-2026/plant_disease
    ```

2.  **Instal dependensi:**
    ```bash
    flutter pub get
    ```

3.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

## Sumber
Dataset: https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset
Model: 
