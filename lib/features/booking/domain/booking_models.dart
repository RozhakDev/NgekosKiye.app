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

class PaymentProofModel {
  final int id;
  final String image;
  final String uploadedAt;

  PaymentProofModel({required this.id, required this.image, required this.uploadedAt});

  factory PaymentProofModel.fromJson(Map<String, dynamic> json) {
    return PaymentProofModel(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

class BookingModel {
  final int id;
  final int room;
  final int kostId;
  final String roomDetails;
  final String kostName;
  final String startDate;
  final int durationMonths;
  final String totalPrice;
  final String status;
  final PaymentProofModel? paymentProof;

  BookingModel({
    required this.id,
    required this.room,
    required this.kostId,
    required this.roomDetails,
    required this.kostName,
    required this.startDate,
    required this.durationMonths,
    required this.totalPrice,
    required this.status,
    this.paymentProof,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? 0,
      room: json['room'] ?? 0,
      kostId: json['kost_id'] ?? json['kost'] ?? 0,
      roomDetails: json['room_details'] ?? '',
      kostName: json['kost_name'] ?? '',
      startDate: json['start_date'] ?? '',
      durationMonths: json['duration_months'] ?? 1,
      totalPrice: json['total_price']?.toString() ?? '0',
      status: json['status'] ?? 'pending_payment',
      paymentProof: json['payment_proof'] != null ? PaymentProofModel.fromJson(json['payment_proof']) : null,
    );
  }
}