/// Mewakili informasi profil pengguna.
///
/// Model ini menyimpan identitas dasar yang ditampilkan di halaman profil.
class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  /// Membentuk objek model dari data JSON API.
  ///
  /// Factory ini digunakan saat respons server perlu dipakai oleh aplikasi.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}