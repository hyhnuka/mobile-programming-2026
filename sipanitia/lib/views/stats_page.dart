import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sipanitia/models/job_model.dart';

class StatsPage extends StatelessWidget {
  final List<Job> jobs;

  const StatsPage({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    // LOGIKA PERHITUNGAN
    int total = jobs.length;
    int done = jobs.where((j) => j.status == "Done").length;
    int todo = total - done;
    double percentage = total > 0 ? (done / total) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Insight Kepanitiaan",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. PROGRESS CIRCULAR CHART
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: CircularProgressIndicator(
                    value: percentage,
                    strokeWidth: 15,
                    backgroundColor: Colors.grey[300],
                    color: percentage > 0.7 ? Colors.green : Colors.orange,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "${(percentage * 100).toInt()}%",
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text("Selesai", style: TextStyle(color: Colors.grey)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 2. SUMMARY CARDS
          Row(
            children: [
              _buildStatCard("Total", total.toString(), Iconsax.note_2, Colors.blue),
              const SizedBox(width: 15),
              _buildStatCard("Done", done.toString(), Iconsax.tick_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard("Todo", todo.toString(), Iconsax.timer_1, Colors.orange),
              const SizedBox(width: 15),
              _buildStatCard("PIC Aktif", _countUniquePics().toString(), Iconsax.user, Colors.purple),
            ],
          ),
          
          const SizedBox(height: 30),
          const Text(
            "Status Terkini",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          
          // Teks Motivasi Berdasarkan Progress
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Text(
              percentage == 1.0 
                ? "Amazing!!! Semua tugas divisi kamu sudah selesai. Pertahankan semangatnya ya!" 
                : "Fighting!!! Ada $todo tugas lagi yang perlu diselesaikan. Cek deadline ya!",
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  int _countUniquePics() {
    return jobs.map((j) => j.pic).toSet().length;
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}