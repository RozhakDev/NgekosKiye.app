import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/booking_repository.dart';
import '../../domain/booking_models.dart';

final paymentMethodsProvider = FutureProvider.family<List<PaymentMethodModel>, int>((ref, kostId) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final res = await repo.getPaymentMethods(kostId);
  
  List<dynamic> rawData;
  if (res.data is Map<String, dynamic> && (res.data as Map<String, dynamic>).containsKey('results')) {
    rawData = res.data['results'] as List<dynamic>;
  } else {
    rawData = res.data as List<dynamic>;
  }
  
  return rawData.map((e) => PaymentMethodModel.fromJson(e)).toList();
});

final bookingHistoryProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final res = await repo.getBookings();
  
  List<dynamic> rawData;
  if (res.data is Map<String, dynamic> && (res.data as Map<String, dynamic>).containsKey('results')) {
    rawData = res.data['results'] as List<dynamic>;
  } else {
    rawData = res.data as List<dynamic>;
  }
  
  return rawData.map((e) => BookingModel.fromJson(e)).toList();
});

final bookingControllerProvider = StateNotifierProvider<BookingController, AsyncValue<BookingModel?>>((ref) {
  return BookingController(ref.watch(bookingRepositoryProvider));
});

class BookingController extends StateNotifier<AsyncValue<BookingModel?>> {
  final BookingRepository _repository;

  BookingController(this._repository) : super(const AsyncValue.data(null));

  Future<BookingModel?> createBooking(int roomId, String startDate, int duration) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.createBooking(
        roomId: roomId,
        startDate: startDate,
        durationMonths: duration,
      );
      final booking = BookingModel.fromJson(response.data);
      state = AsyncValue.data(booking);
      return booking;
    } on DioException catch (e) {
      state = AsyncValue.error(e.response?.data['detail'] ?? 'Gagal membuat pesanan.', e.stackTrace);
      return null;
    }
  }

  Future<bool> uploadPayment(int bookingId, File image) async {
    state = const AsyncValue.loading();
    try {
      await _repository.uploadPaymentProof(bookingId, image);
      state = const AsyncValue.data(null);
      return true;
    } on DioException catch (e) {
      state = AsyncValue.error(e.response?.data['pesan'] ?? 'Gagal mengunggah bukti.', e.stackTrace);
      return false;
    }
  }
}