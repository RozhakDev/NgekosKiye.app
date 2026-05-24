/// Mewakili informasi utama sebuah kos.
///
/// Model ini menyimpan data dasar seperti nama, lokasi, harga, dan gambar.
class KostModel {
  final int id;
  final String name;
  final String address;
  final String description;
  final String facilities;
  final String latitude;
  final String longitude;
  final String minPrice;
  final List<String> images;
  final List<RoomModel>? rooms;

  KostModel({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.facilities,
    required this.latitude,
    required this.longitude,
    required this.minPrice,
    required this.images,
    this.rooms,
  });

  /// Membentuk objek model dari data JSON API.
  ///
  /// Factory ini digunakan saat respons server perlu dipakai oleh aplikasi.
  factory KostModel.fromJson(Map<String, dynamic> json) {
    var imgList = json['images'] as List? ?? [];
    List<String> imageUrls = imgList.map((i) => i['image'].toString()).toList();

    var roomList = json['rooms'] as List? ?? [];
    List<RoomModel> rooms = roomList.map((r) => RoomModel.fromJson(r)).toList();

    return KostModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      description: json['description'] ?? '',
      facilities: json['facilities'] ?? '',
      latitude: json['latitude'] ?? '0.0',
      longitude: json['longitude'] ?? '0.0',
      minPrice: json['min_price']?.toString() ?? '0',
      images: imageUrls,
      rooms: rooms,
    );
  }
}

/// Mewakili informasi kamar yang tersedia pada kos.
///
/// Model ini digunakan untuk menampilkan pilihan kamar dan harga sewa.
class RoomModel {
  final int id;
  final String roomNumber;
  final String price;
  final String status;
  final List<String> images;

  RoomModel({
    required this.id, 
    required this.roomNumber, 
    required this.price, 
    required this.status,
    required this.images,
  });

  /// Membentuk objek model dari data JSON API.
  ///
  /// Factory ini digunakan saat respons server perlu dipakai oleh aplikasi.
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    var imgList = json['images'] as List? ?? [];
    List<String> imageUrls = imgList.map((i) => i['image'].toString()).toList();

    return RoomModel(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      price: json['price']?.toString() ?? '0',
      status: json['status'] ?? 'available',
      images: imageUrls,
    );
  }
}