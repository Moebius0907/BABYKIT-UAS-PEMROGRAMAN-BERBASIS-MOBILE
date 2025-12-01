import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserAddress = 'user_address';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // Simpan session user dari API
  Future<void> saveUserSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil dari key 'user_id' sesuai API
    await prefs.setInt(
      _keyUserId,
      int.tryParse(userData['user_id'].toString()) ?? 0,
    );
    await prefs.setString(_keyUserName, userData['name'] ?? '');
    await prefs.setString(_keyUserEmail, userData['email'] ?? '');
    await prefs.setString(_keyUserPhone, userData['phone'] ?? '');
    await prefs.setString(_keyUserAddress, userData['address'] ?? '');
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  // Ambil session user
  Future<Map<String, dynamic>> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': prefs.getInt(_keyUserId) ?? 0,
      'name': prefs.getString(_keyUserName) ?? '',
      'email': prefs.getString(_keyUserEmail) ?? '',
      'phone': prefs.getString(_keyUserPhone) ?? '',
      'address': prefs.getString(_keyUserAddress) ?? '',
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
    };
  }

  // Update alamat lokal
  Future<void> updateAddressLocally(String newAddress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserAddress, newAddress);
  }

  // Hapus session
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserAddress);
    await prefs.remove(_keyIsLoggedIn);
  }
}
