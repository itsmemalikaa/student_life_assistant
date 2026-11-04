import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../repositories/account_repository.dart';
import '../repositories/storage_scope.dart';

/// Mengelola akun lokal: daftar (registrasi) dan masuk (login) dengan nama.
class AccountController extends ChangeNotifier {
  AccountController({AccountRepository? repository})
      : _repository = repository ?? AccountRepository();

  final AccountRepository _repository;

  List<Account> _accounts = [];
  String? _currentId;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isEmpty => _accounts.isEmpty;
  List<Account> get accounts => List.unmodifiable(_accounts);

  /// Akun yang terakhir dipakai di perangkat ini.
  Account? get current {
    for (final a in _accounts) {
      if (a.id == _currentId) return a;
    }
    return _accounts.isEmpty ? null : _accounts.first;
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _accounts = await _repository.loadAll();
      _currentId = await _repository.loadCurrentId();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login kalau nama sudah terdaftar, daftar akun baru kalau belum.
  /// Nama dibandingkan tanpa memperhatikan huruf besar/kecil.
  Future<Account> loginOrRegister(String name) async {
    final cleaned = name.trim();
    for (final a in _accounts) {
      if (a.name.toLowerCase() == cleaned.toLowerCase()) {
        await select(a);
        return a;
      }
    }
    final account = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: cleaned,
    );
    _accounts = [..._accounts, account];
    await _repository.saveAll(_accounts);
    await select(account);
    return account;
  }

  /// Menjadikan akun ini sebagai pengguna aktif.
  Future<void> select(Account account) async {
    _currentId = account.id;
    StorageScope.use(account.storagePrefix);
    notifyListeners();
    await _repository.saveCurrentId(account.id);
  }

  Future<void> rename(String id, String newName) async {
    _accounts = _accounts
        .map((a) => a.id == id ? a.copyWith(name: newName.trim()) : a)
        .toList();
    notifyListeners();
    await _repository.saveAll(_accounts);
  }
}
