import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mobile/core/constants/api_constants.dart';

class NutritionService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.nutritionUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<Map<String, dynamic>> analyzeFood({
    required String text,
    File? image,
    int portion = 1,
  }) async {
    try {
      final formData = FormData.fromMap({
        'text': text,
        'portion': portion,
        if (image != null)
          'image': await MultipartFile.fromFile(
            image.path,
            filename: 'food.jpg',
          ),
      });

      final response = await _dio.post(ApiConstants.analyzeFood, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to analyze food: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> generateWorkout({
    required int totalKcal,
    required List<Map<String, dynamic>> meals,
  }) async {
    try {
      final formData = FormData.fromMap({
        'total_kcal': totalKcal,
        'meals': jsonEncode(meals),
      });

      final response = await _dio.post(ApiConstants.generateWorkoutPlan, data: formData);
      return response.data;
    } catch (e) {
      throw Exception('Failed to generate workout: $e');
    }
  }

  Future<String> chat({
    required String message,
    List<Map<String, dynamic>> history = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'message': message,
        'history': history,
      });

      final response = await _dio.post(ApiConstants.nutritionChat, data: formData);
      return response.data['response'];
    } catch (e) {
      throw Exception('Failed to chat: $e');
    }
  }
}
