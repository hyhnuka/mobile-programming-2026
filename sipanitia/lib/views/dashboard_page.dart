import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sipanitia/database/db_helper.dart';
import 'package:sipanitia/models/job_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sipanitia/services/notification_service.dart'; // Sesuaikan dengan nama folder kamu
import 'package:sipanitia/views/stats_page.dart';


class DashboardPage extends StatefulWidget {
  final String role;
  final String name;
  // Kita tidak perlu lempar divisi lewat constructor jika kita ambil langsung di Dashboard
  const DashboardPage({
    super.key, 
    required this.role, 
    required this.name}
    );

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final Color _deepSkyBlue = const Color(0xFF0288D1);
  final Color _softBlue = const Color(0xFFE3F2FD);
  int _selectedIndex = 0;

  String _userDivisi = "-"; // Default value
  bool _isLoadingProfile = true;
  List<String> _memberList = [];
  String _userName = "Panitia";

  final DBHelper _dbHelper = DBHelper();
  List<Job> _jobs = [];
  bool _hasnotified = false;


  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // _loadJobs();
    _loadUserProfile();
  }

  Future<void> _loadJobs() async {
    if (_userDivisi == "..." || _userDivisi == "-") return;

    print("Memuat data untuk divisi: $_userDivisi");

    final data = await _dbHelper.getJobs(
      _userDivisi, 
      picName: _userName, // Nama user yang didapat dari Firestore
      role: widget.role    // Role yang didapat dari halaman login
    );

    bool isDataChanged = false;
    if (_jobs.isNotEmpty && data.isNotEmpty) {
      if (_jobs.first.deadline != data.first.deadline) {
        isDataChanged = true; 
      }
    }
    
    setState(() {
      _jobs = data;
    });

    // LOGIKA NOTIFIKASI OTOMATIS SAAT LOGIN (Untuk Member)
    if (widget.role == 'member' && _jobs.isNotEmpty && (!_hasnotified || isDataChanged)) {
    // Ambil tugas terakhir atau yang terbaru
    final latestJob = _jobs.first;
    
    NotificationService.showNotification(
      _userName, 
      "Update ${latestJob.jobdesk}", 
      "Update: ${latestJob.deadline}"
    );
    
    _hasnotified = true; // Set true agar tidak muncul setiap kali refresh
  }

  }


  // ================= PROFILE =================
  Future<void> _loadUserProfile() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        String currentDivisi = doc.data()?['divisi'] ?? "-";
        String currentName = doc.data()?['nama'] ?? "Panitia";

        setState(() {
          _userName = currentName;
          _userDivisi = currentDivisi;
          _isLoadingProfile = false;
        });
        
        // PENTING: Tunggu sampai daftar member selesai diambil
        await _fetchMembersByDivisi(currentDivisi);
        
        // Baru muat daftar pekerjaannya
        await _loadJobs(); 
      }
    }
  } catch (e) {
    print("Error load profile: $e");
  }
}
// Fungsi ini bisa dipanggil setelah kita mendapatkan divisi admin, misal di _loadUserProfile setelah setState
Future<void> _fetchMembersByDivisi(String adminDivisi) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('divisi', isEqualTo: adminDivisi)
        .where('role', isEqualTo: 'member')
        .get();

    setState(() {
      _memberList = snapshot.docs.map((doc) {
      return (doc.data()['nama'] as String?) ?? "Tanpa Nama";      }).toList();
    });

    print("MEMBER DITEMUKAN: ${_memberList.length}");
  } catch (e) {
    print("Error fetch members: $e");
  }
}

  // ================= CAMERA =================
  Future<void> _pickImageFromCamera(Job job) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Opsional: kompres gambar agar tidak terlalu berat
    );

    if (pickedFile != null) {
      // Pastikan path foto dimasukkan ke objek job
      setState(() {
        job.buktiFoto = pickedFile.path; 
        job.status = "Done";
      });

      // Simpan ke Database
      await _dbHelper.updateJob(job);
      
      // Refresh data dari database agar UI sinkron
      await _loadJobs(); 
      
      print("DEBUG: Foto berhasil diambil di path: ${pickedFile.path}");
    }
  }

  //=====Date Picker=====
  Future<void> _selectDeadline(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Tidak bisa pilih tanggal lampau
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }

  // ================= UI =================
@override
  Widget build(BuildContext context) {
    // 1. LIST HALAMAN (Definisikan di sini)
    final List<Widget> _pages = [
      // TAB 0: HALAMAN HOME (Daftar Tugas)
      Column(
        children: [
          _header(),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text("Daftar Pekerjaan",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: _jobs.isEmpty
                ? const Center(child: Text("Belum ada pekerjaan"))
                : ListView.builder(
                    itemCount: _jobs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) => _buildJobCard(_jobs[index]),
                  ),
          ),
        ],
      ),
      
      // TAB 1: HALAMAN STATISTIK
      StatsPage(jobs: _jobs),
    ];

    return Scaffold(
      backgroundColor: _softBlue,
      appBar: AppBar(
        backgroundColor: _deepSkyBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "SiPanitia", 
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),

      // FIX 1: Body hanya memanggil list _pages berdasarkan index yang dipilih
      body: _pages[_selectedIndex],

      // FIX 2: Tombol Tambah hanya muncul jika di Tab 0 (Home) dan role-nya Admin
      floatingActionButton: (_selectedIndex == 0 && widget.role == 'admin')
          ? FloatingActionButton(
              backgroundColor: _deepSkyBlue,
              child: const Icon(Iconsax.add),
              onPressed: _showAddJobModal,
            )
          : null,

      // FIX 3: Tambahkan BottomNavigationBar agar bisa pindah tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: _deepSkyBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.chart_21),
            label: "Insight",
          ),
        ],
      ),
    );
  }

  Widget _header() {
    // Fungsi pembantu untuk membuat huruf pertama kapital (admin -> Admin)
    String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _deepSkyBlue,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24, // Kasih warna background dikit biar cakep
            child: Icon(Iconsax.user, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $_userName!",
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 18, 
                  fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 4),
              // Menampilkan: Admin Acara atau Member Konsumsi
              _isLoadingProfile 
                ? const SizedBox(
                    height: 12, 
                    width: 12, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)
                  )
                : Text(
                    "${capitalize(widget.role)} $_userDivisi",
                    style: const TextStyle(
                      color: Colors.white70, 
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= CARD =================
  Widget _buildJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= BARIS 1 =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobdesk,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Iconsax.timer_1,
                            size: 14, color: Colors.redAccent),
                        const SizedBox(width: 5),
                        Text(
                          "Deadline: ${job.deadline}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (widget.role == 'admin')
                Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Iconsax.edit,
                          color: Colors.orange, size: 20),
                      onPressed: () => _showEditJobModal(job),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      icon: const Icon(Iconsax.trash,
                          color: Colors.red, size: 20),
                      onPressed: () =>
                          _showDeleteDialog(job.id!),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // ================= BARIS 2 =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PIC: ${job.pic}",
                style: const TextStyle(fontSize: 14),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: job.status == "Done"
                      ? Colors.green
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  job.status,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ================= BARIS 3 =================
          if (job.buktiLink.isNotEmpty)
            Container( // Hapus GestureDetector, ganti jadi Container biasa
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Iconsax.note_2, size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        "Catatan:", 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    job.buktiLink, // Ini berisi teks catatan atau link dari member
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

          // ================= BARIS 4 =================
          if (widget.role == 'member')
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Iconsax.edit_2, size: 16),
                  onPressed: () => _showUpdateBuktiModal(job),
                  label: const Text("Update Progress"),
                ),
              ),
            ),

           // ================= BARIS 5 TAMPILAN FOTO BUKTI =================
          if (job.buktiFoto.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bukti Foto:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(job.buktiFoto), // Pastikan sudah import 'dart:io'
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      // Jika file hilang atau path salah, tampilkan error ringan
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text("Foto tidak dapat dimuat")),
                      ),
                    ),
                  ),
                ],
              ),
            ), 
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == "Done") color = Colors.green;
    if (status == "In Progress") color = Colors.orange;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(status, style: TextStyle(color: color)),
    );
  }

  // ================= ADD JOB =================
  void _showAddJobModal() {
    final jobdeskController = TextEditingController();
    String? selectedPic = _memberList.isNotEmpty ? _memberList[0] : null;
    DateTime? selectedDeadline; // Variabel untuk menampung tanggal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20, right: 20, top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Tambah Tugas Baru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),

                  TextField(
                    controller: jobdeskController,
                    decoration: const InputDecoration(labelText: "Nama Jobdesk", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 15),

                  // 1. INPUT DEADLINE 
                  ListTile(
                    leading: const Icon(Iconsax.calendar_1, color: Colors.blue),
                    title: Text(
                      selectedDeadline == null 
                        ? "Pilih Deadline" 
                        : "Deadline: ${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}"
                    ),
                    tileColor: Colors.grey[100],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      print("Membuka Kalender...");
                      final DateTime? picked = await showDatePicker(
                        context: Navigator.of(context).context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2027),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(primary: Colors.blue),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        print("Tanggal berhasil dipilih: $picked");
                        setModalState(() {
                          selectedDeadline = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: selectedPic,
                    items: _memberList.isEmpty
                        ? [const DropdownMenuItem(value: null, child: Text("Sedang memuat member..."))]
                        : _memberList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) => setModalState(() => selectedPic = val),
                    decoration: const InputDecoration(labelText: "Pilih PIC", border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    onPressed: () async {
                      // Validasi: Deadline juga wajib diisi
                      if (jobdeskController.text.isEmpty || selectedPic == null || selectedDeadline == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Harap isi Nama Tugas, PIC, dan Deadline!")),
                        );
                        return;
                      }

                      try {
                        String formattedDeadline = "${selectedDeadline!.day}/${selectedDeadline!.month}/${selectedDeadline!.year}";

                        
                        print("DEBUG: Menyiapkan data simpan...");
                        print("Jobdesk: ${jobdeskController.text}");
                        print("PIC: $selectedPic");
                        print("Divisi: $_userDivisi");
                        print("Deadline: $formattedDeadline");

                        // 1. SIMPAN KE DATABASE LOKAL (SQLite)
                        await _dbHelper.insertJob(Job(
                          jobdesk: jobdeskController.text,
                          pic: selectedPic!,
                          status: "Todo",
                          buktiFoto: "",
                          buktiLink: "",
                          divisi: _userDivisi ?? "-",
                          deadline: formattedDeadline, // Pastikan kolom ini sudah ada di DB Versi 4
                        ));

                        // 2. LOGIKA NOTIFIKASI YANG DIPERBAIKI
                        if (selectedPic == widget.name) { 
                          await NotificationService.showNotification(
                            selectedPic!, 
                            jobdeskController.text, 
                            formattedDeadline
                          );
                          print("DEBUG: Notifikasi dikirim untuk $selectedPic");
                        } else {
                          print("DEBUG: Notifikasi tidak muncul di HP ini karena PIC ($selectedPic) bukan Anda (${widget.name})");
                        }

                        await _loadJobs();
                        if (!mounted) return;
                        Navigator.pop(context);
                      } catch (e) {
                        print("ERROR SAAT SIMPAN: $e");
                      }
                    },
                    child: const Text("Simpan & Kirim Notif"),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
  // ================= UPDATE =================
  void _showUpdateBuktiModal(Job job) {
      showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Update Progress Tugas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            
            // OPSI 1: Ubah ke In Progress (Hanya muncul jika status masih Todo)
            if (job.status == "Todo")
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Icon(Iconsax.play, color: Colors.white, size: 20),
                ),
                title: const Text("Mulai Kerjakan"),
                subtitle: const Text("Ubah status menjadi In Progress"),
                onTap: () async {
                  job.status = "In Progress";
                  await _dbHelper.updateJob(job);
                  await _loadJobs(); // Refresh list
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Status diperbarui: In Progress")),
                  );
                },
              ),

            // OPSI 2: Kamera (Otomatis Done)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Iconsax.camera, color: Colors.white, size: 20),
              ),
              title: const Text("Ambil Foto Bukti"),
              subtitle: const Text("Tugas akan dianggap Selesai (Done)"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera(job);
              },
            ),

            // OPSI 3: Link (Otomatis Done)
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Iconsax.link, color: Colors.white, size: 20),
              ),
              title: const Text("Tambah Catatan"), 
              subtitle: const Text("Input link atau keterangan progres"),
              onTap: () {
                Navigator.pop(context);
                _showCatatanDialog(job);
              },
            ),
          ],
        ),
      ),
    );
  }
  //================= UPDATE LINK =================
  void _showCatatanDialog(Job job) {
    final controller = TextEditingController(text: job.buktiLink); // Ambil data lama jika ada

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tambah Catatan / Link"),
        content: TextField(
          controller: controller,
          maxLines: 3, // Biar bisa input panjang
          decoration: const InputDecoration(
            hintText: "Masukkan link atau catatan progres...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              job.buktiLink = controller.text; // Simpan ke field buktiLink
              job.status = "Done";
              await _dbHelper.updateJob(job);
              await _loadJobs();
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  //================= DELETE JOB =================
  void _showDeleteDialog(int jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Tugas?"),
        content: const Text("Tugas ini akan dihapus permanen dari database lokal."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteJob(jobId);
              await _loadJobs();
              if (!mounted) return;
              Navigator.pop(context);
            }, 
            child: const Text("Hapus", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  //================= EDIT JOB =================
  void _showEditJobModal(Job job) {
    final editController = TextEditingController(text: job.jobdesk);
    String selectedPic = job.pic;
    final deadlineController = TextEditingController(text: job.deadline); // Controller untuk deadline
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Tugas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 15),
              // Input untuk nama jobdesk
              TextField(
                controller: editController,
                decoration: const InputDecoration(labelText: "Update Nama Jobdesk", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              // Input PIC (Dropdown)
              DropdownButtonFormField<String>(
                value: selectedPic,
                items: _memberList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setModalState(() => selectedPic = val!),
                decoration: const InputDecoration(labelText: "Update PIC", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              // 2. INPUT DEADLINE (Taruh di sini, di dalam children)
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2027),
                  );
                  if (picked != null) {
                    setModalState(() {
                      deadlineController.text = "${picked.day}/${picked.month}/${picked.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: deadlineController,
                    decoration: const InputDecoration(
                      labelText: "Update Deadline",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.calendar_1),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              //Tombol Simpan Perubahan
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () async {
                  job.jobdesk = editController.text;
                  job.pic = selectedPic;
                  job.deadline = deadlineController.text;
                  await _dbHelper.updateJob(job);
                  await _loadJobs();
                  if (!mounted) return;
                  Navigator.pop(context);
                },
                child: const Text("Simpan Perubahan"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  //================= LOGOUT =================
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              // 1. Sign out dari Firebase agar sesi berakhir
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;
              
              // 2. Hapus semua tumpukan halaman dan balik ke Login
              // Kita pakai pushNamedAndRemoveUntil supaya user gak bisa klik 'back' lagi ke Dashboard
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}