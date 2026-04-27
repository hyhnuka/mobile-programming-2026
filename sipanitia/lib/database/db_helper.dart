import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sipanitia/models/job_model.dart';

class DBHelper {
  // Singleton pattern
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'job.db');
    return await openDatabase(
      path,
      version: 4, // Naikkan versi dari 1 ke 4
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jobs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jobdesk TEXT,
            pic TEXT,
            status TEXT,
            bukti_foto TEXT,
            bukti_link TEXT,
            divisi TEXT,
            deadline TEXT 
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 2) {
        // Pastikan kolom divisi ada jika upgrade dari versi 1
        await db.execute("ALTER TABLE jobs ADD COLUMN divisi TEXT");
        }
        if (oldVersion < 3) {
          await db.execute("ALTER TABLE jobs ADD COLUMN bukti_foto TEXT");
          await db.execute("ALTER TABLE jobs ADD COLUMN bukti_link TEXT");
        }
        if (oldVersion < 4) {
          await db.execute("ALTER TABLE jobs ADD COLUMN deadline TEXT");
        }
        
      },
    );
  }



  // CREATE
  Future<int> insertJob(Job job) async {
    final db = await database;
    print("Proses insert ke SQLite: ${job.toMap()}"); // Tambahkan ini untuk debug
    return await db.insert('jobs', job.toMap());
  }

  // READ (Ditambah Order By agar yang terbaru di atas)
  Future<List<Job>> getJobs(String divisi, {String? picName, String? role}) async {
    final db = await database;
    if (role == 'admin') {
    // Admin melihat semua tugas di divisinya
      final List<Map<String, dynamic>> maps = await db.query(
        'jobs',
        where: 'divisi = ?',
        whereArgs: [divisi],
        orderBy: 'id DESC',
      );
      return maps.map((e) => Job.fromMap(e)).toList();
    } else {
      // Member HANYA melihat tugas yang PIC-nya adalah namanya sendiri
      final List<Map<String, dynamic>> maps = await db.query(
        'jobs',
        where: 'divisi = ? AND pic = ?',
        whereArgs: [divisi, picName],
        orderBy: 'id DESC',
      );
      return maps.map((e) => Job.fromMap(e)).toList();
    }
  }

  // UPDATE
  Future<int> updateJob(Job job) async {
    final db = await database;
    return await db.update(
      'jobs',
      job.toMap(),
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  // DELETE
  Future<int> deleteJob(int id) async {
    final db = await database;
    return await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }
}