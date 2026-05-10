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
<p align="center">
  <img src="https://github.com/user-attachments/assets/57a9192f-61df-4de3-ad73-c2981cc4a4c5" width="25%"/>
  <img src="https://github.com/user-attachments/assets/41f1551f-9b95-4b3f-9ef0-5a9768434685" width="25%"/>
  <img src="https://github.com/user-attachments/assets/237f81e7-d47b-442a-b046-8bc761dc7674" width="25%"/>
</p>

---

## Arsitektur & Teknologi

**Framework**: Flutter  
**Machine Learning**: TensorFlow Lite (tflite_v2)  
**Database Lokal**: SQLite (sqflite)  
**Storage**: Path Provider  
**Image Resource**: Image Picker (Camera & Gallery)  
**Model**: Custom .tflite Plant Disease Classification Model  

---

## Struktur Folder

```bash
lib/
├── main.dart              
├── screens/               # UI aplikasi
├── services/              # Database & Classifier AI
└── widgets/               # Komponen widget reusable

assets/
├── model_unquant.tflite   # Model AI
├── labels.txt             # Label kelas penyakit
└── explain-label.json     # Database informasi penyakit
```
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

## Sumber Referensi
**AI Model**: Menggunakan model TFLite yang digunakan oleh root458 (via Teachable Machine).
**Dataset**: Kaggle
