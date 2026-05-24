import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(dioProvider));
});

/// Menghubungkan fitur pemesanan dengan endpoint API.
///
/// Class ini menangani akses data booking dan pembayaran.
class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  /// Mengambil daftar pemesanan milik pengguna.
  ///
  /// Method ini digunakan untuk mengisi halaman riwayat booking.
  Future<Response> getBookings() async {
    return await _dio.get('/bookings/');
  }

  /// Mengambil detail pemesanan berdasarkan ID.
  ///
  /// Method ini digunakan saat pengguna membuka satu booking.
  Future<Response> getBookingDetail(int id) async {
    return await _dio.get('/bookings/$id/');
  }

  /// Mengambil metode pembayaran yang tersedia untuk kos tertentu.
  ///
  /// Method ini membantu pengguna memilih cara pembayaran.
  Future<Response> getPaymentMethods(int kostId) async {
    return await _dio.get('/kosts/$kostId/payment-methods/');
  }

  Future<Response> createBooking({
    required int roomId,
    required String startDate,
    required int durationMonths,
  }) async {
    return await _dio.post('/bookings/', data: {
      'room': roomId,
      'start_date': startDate,
      'duration_months': durationMonths,
    });
  }

  /// Mengunggah gambar bukti pembayaran untuk pemesanan.
  ///
  /// Method ini mengirim file pembayaran ke server.
  Future<Response> uploadPaymentProof(int bookingId, File imageFile) async {
    String fileName = imageFile.path.split('/').last;
    
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
    });

    return await _dio.post(
      '/bookings/$bookingId/upload_payment/',
      data: formData,
    );
  }
}