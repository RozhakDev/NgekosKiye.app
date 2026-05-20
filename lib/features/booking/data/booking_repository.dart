import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(dioProvider));
});

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  Future<Response> getBookings() async {
    return await _dio.get('/bookings/');
  }

  Future<Response> getBookingDetail(int id) async {
    return await _dio.get('/bookings/$id/');
  }

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