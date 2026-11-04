/// Memisahkan data setiap pengguna di penyimpanan lokal.
///
/// Semua key shared_preferences milik pengguna diberi awalan (prefix)
/// sesuai id akunnya, misalnya `u_1730000000.tasks.v1`. Jadi tugas,
/// jadwal, keuangan, dan preferensi setiap nama tidak tercampur.
class StorageScope {
  static String _prefix = '';

  /// Dipanggil saat pengguna masuk (login) ke akunnya.
  static void use(String prefix) => _prefix = prefix;

  /// Key lengkap untuk pengguna yang sedang aktif.
  static String key(String base) => '$_prefix$base';
}
