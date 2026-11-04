/// Akun pengguna lokal (tanpa password) di perangkat ini.
class Account {
  const Account({required this.id, required this.name});

  /// Akun untuk data lama (sebelum ada fitur akun). Datanya disimpan
  /// tanpa prefix, jadi data yang sudah ada tidak hilang.
  static const legacyId = 'legacy';

  final String id;
  final String name;

  /// Awalan key penyimpanan milik akun ini.
  String get storagePrefix => id == legacyId ? '' : 'u_$id.';

  Account copyWith({String? name}) => Account(id: id, name: name ?? this.name);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(id: json['id'] as String, name: json['name'] as String);
  }
}
