import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Controller & State
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedDivisi;
  String? _selectedRole; // Tambahkan ini di bawah _selectedDivisi
  final List<String> _listRole = ['admin', 'member']; // Pilihan role
  final TextEditingController _nameController = TextEditingController(); // Tambahkan ini

  final List<String> _listDivisi = [
    'Acara', 'Logistik', 'Konsumsi', 'Humas', 'Dekorasi & Dokumentasi', 'Perlengkapan'
  ];

  // 2. Definisi Warna
  final Color _softBlue = const Color(0xFFE3F2FD);
  final Color _skyBlueAccent = const Color(0xFF4FC3F7);
  final Color _deepSkyBlue = const Color(0xFF0288D1);
  final Color _darkText = const Color(0xFF263238);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 3. Fungsi Register (Sudah diperbaiki strukturnya)
  void _doRegister() async {
    String nama = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty || _selectedDivisi == null || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data dengan benar'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // STEP 1: Register ke Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // STEP 2: Simpan ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid,
        'nama': _nameController.text.trim(),
        'email': email,
        'divisi': _selectedDivisi,
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Berhasil!')),
      );

      Navigator.pop(context); // Kembali ke Login

    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Registrasi Gagal"), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Terjadi kesalahan sistem"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_softBlue, _skyBlueAccent.withOpacity(0.6)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Iconsax.arrow_left_2, color: _deepSkyBlue),
                  ),
                  const SizedBox(height: 20),
                  Text("Daftar Panitia",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _deepSkyBlue)),
                  const SizedBox(height: 10),
                  Text("Buat akun untuk mulai mengelola tugas",
                    style: TextStyle(color: _darkText.withOpacity(0.6))),
                  const SizedBox(height: 40),

                  // TextField Nama
                  _buildTextField(
                      controller: _nameController,
                      hintText: "Nama",
                      icon: Iconsax.user, 
                    ),
                  const SizedBox(height: 20),

                  // TextField Email
                  _buildTextField(
                    controller: _emailController,
                    hintText: "Email Panitia",
                    icon: Iconsax.sms,
                  ),
                  const SizedBox(height: 20),

                  // TextField Password
                  _buildTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    icon: Iconsax.key,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onSuffixIconPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Divisi
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDivisi,
                        hint: Text("Pilih Divisi", style: TextStyle(color: _darkText.withOpacity(0.4))),
                        icon: Icon(Iconsax.arrow_down_1, color: _skyBlueAccent),
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: _listDivisi.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: _darkText)),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _selectedDivisi = newValue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Dropdown Role
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        hint: Text("Pilih Role", style: TextStyle(color: _darkText.withOpacity(0.4))),
                        icon: Icon(Iconsax.arrow_down_1, color: _skyBlueAccent),
                        decoration: const InputDecoration(border: InputBorder.none),
                        items: _listRole.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: _darkText)),
                          );
                        }).toList(),
                        onChanged: (newValue) => setState(() => _selectedRole = newValue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _doRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _deepSkyBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("DAFTAR SEKARANG",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onSuffixIconPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          prefixIcon: Icon(icon, color: _skyBlueAccent),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscureText ? Iconsax.eye : Iconsax.eye_slash),
                  onPressed: onSuffixIconPressed,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}