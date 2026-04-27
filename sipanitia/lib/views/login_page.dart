// ==========================================
// File: views/login_page.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart'; 
import 'package:sipanitia/views/dashboard_page.dart';
import 'package:sipanitia/views/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk menangkap input teks
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // State untuk menyembunyikan/menampilkan password
  bool _obscurePassword = true;

  // Definisi Warna Tema (Soft Blue & Biru Angkasa)
  final Color _softBlue = const Color(0xFFE3F2FD); // Light Blue 50
  final Color _skyBlueAccent = const Color(0xFF4FC3F7); // Light Blue 300
  final Color _deepSkyBlue = const Color(0xFF0288D1); // Light Blue 700 (Biru Angkasa)
  final Color _darkText = const Color(0xFF263238); // Blue Grey 900

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _doLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi Email dan Password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // 🔄 Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. Proses Login Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ambil User ID yang baru saja login
      String uid = userCredential.user!.uid;

      // 2. Ambil Data Role dari Firestore (INI QUERY-NYA)
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        if (mounted) Navigator.pop(context);
        throw "Data user tidak ditemukan di database.";
      }

      // Ambil string role dari database (admin atau member)
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      String userRole = data['role'] ?? 'member'; 
      String userName = data['nama'] ?? 'Panitia';

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              role: userRole, 
              name: userName, 
            ),
          ),
        );
      }
  } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);
      // ... handle error ...
    } catch (e) {
      if (mounted) Navigator.pop(context);
      // ... handle error ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Stack untuk background gradasi
      body: Stack(
        children: [
          // 1. Background Gradient (Soft Blue to Sky Blue)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _softBlue,
                  _skyBlueAccent.withOpacity(0.6),
                ],
              ),
            ),
          ),
          
          // 2. Konten Login (Scrollable agar tidak error di layar kecil)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // -- Header Section --
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.task_square5, // Icon Logo Aplikasi
                      size: 50,
                      color: _deepSkyBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "SiPanitia",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _deepSkyBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    "Event Job Tracker",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _darkText.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // -- Form Section --
                  // Input Email
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Email Divisi / Anggota",
                    icon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Input Password
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Iconsax.key,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onSuffixIconPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  
                  // Lupa Password (Optional, untuk mempercantik UI)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TAHAP LANJUTAN: Fitur Reset Password
                      },
                      child: Text(
                        "Lupa Password?",
                        style: TextStyle(color: _deepSkyBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // -- Button Section --
                  // Tombol Login (Biru Angkasa)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _doLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _deepSkyBlue,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: _deepSkyBlue.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "MASUK",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Belum punya akun?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                          child: Text("Daftar di sini", style: TextStyle(color: _deepSkyBlue, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 40),
                  
                  // -- Footer Section (Optional) --
                  // Center(
                  //   child: Text(
                  //     "v1.0.0 - Kampus Edition",
                  //     style: TextStyle(
                  //       fontSize: 12,
                  //       color: _darkText.withOpacity(0.5),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk membuat TextField yang seragam
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onSuffixIconPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3), // shadow direction: bottom
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: _darkText),
        decoration: InputDecoration(
          border: InputBorder.none, // Hilangkan border bawaan
          hintText: hintText,
          hintStyle: TextStyle(color: _darkText.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: _skyBlueAccent),
          // Tampilkan icon mata jika itu field password
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Iconsax.eye : Iconsax.eye_slash,
                    color: _darkText.withOpacity(0.4),
                  ),
                  onPressed: onSuffixIconPressed,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}