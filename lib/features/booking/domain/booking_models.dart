class PaymentMethodModel {
  final int id;
  final String name;
  final String? image;

  PaymentMethodModel({required this.id, required this.name, this.image});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Metode Pembayaran',
      image: json['image'],
    );
  }
}

class BookingModel {
  final int id;
  final String startDate;
  final int durationMonths;
  final String totalPrice;
  final String status;

  BookingModel({
    required this.id,
    required this.startDate,
    required this.durationMonths,
    required this.totalPrice,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      startDate: json['start_date'] ?? '',
      durationMonths: json['duration_months'] ?? 1,
      totalPrice: json['total_price']?.toString() ?? '0',
      status: json['status'] ?? 'pending',
    );
  }
}