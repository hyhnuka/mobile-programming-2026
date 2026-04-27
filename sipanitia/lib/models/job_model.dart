// models/job_model.dart
class Job {
  int? id;
  String jobdesk;
  String pic;
  String status;
  String buktiFoto; 
  String buktiLink; 
  String divisi;
  String deadline;

  Job({
    this.id, 
    required this.jobdesk, 
    required this.pic, 
    required this.status, 
    required this.buktiFoto,
    required this.buktiLink,
    required this.divisi,
    required this.deadline
  });

  // Untuk konversi dari Map (Database) ke Object (Flutter)
  factory Job.fromMap(Map<String, dynamic> json) => Job(
      id: json['id'],
      jobdesk: json['jobdesk'] ?? "",     // Jika null, kasih teks kosong
      pic: json['pic'] ?? "",             // Jika null, kasih teks kosong
      status: json['status'] ?? "Todo",   // Jika null, set default "Todo"
      buktiFoto: json['bukti_foto'] ?? "", // Penjaga agar tidak error Null
      buktiLink: json['bukti_link'] ?? "", // Penjaga agar tidak error Null
      divisi: json['divisi'] ?? "-",      // Penjaga agar tidak error Null
      deadline: json['deadline'] ?? "",   // Penjaga agar tidak error Null
    );

  // Untuk konversi dari Object ke Map (untuk Insert/Update ke DB)
  Map<String, dynamic> toMap() => {
        'id': id,
        'jobdesk': jobdesk,
        'pic': pic,
        'status': status,
        'bukti_foto': buktiFoto ?? "-",
        'bukti_link': buktiLink ?? "-",
        'divisi': divisi ?? "-",
        'deadline': deadline ?? "",
      };
}