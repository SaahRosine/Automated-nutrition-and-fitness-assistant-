import 'dart:io';
import 'package:flutter/material.dart';
import '../services/nutrition_service.dart';

class NutritionProvider extends ChangeNotifier {
  final NutritionService _service = NutritionService();
  
  Map<String, dynamic>? _lastAnalysis;
  Map<String, dynamic>? get lastAnalysis => _lastAnalysis;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  final List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> get meals => _meals;

  int get totalCalories => _meals.fold(0, (sum, item) => sum + (item['calories'] as int? ?? 0));

  Future<void> analyzeFood({required String text, File? image, int portion = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastAnalysis = await _service.analyzeFood(text: text, image: image, portion: portion);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? _workoutPlan;
  Map<String, dynamic>? get workoutPlan => _workoutPlan;

  Future<void> generateWorkout() async {
    if (_meals.isEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workoutPlan = await _service.generateWorkout(
        totalKcal: totalCalories,
        meals: _meals,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logMeal() {
    if (_lastAnalysis != null) {
      _meals.add(Map<String, dynamic>.from(_lastAnalysis!));
      _lastAnalysis = null;
      notifyListeners();
    }
  }

  void clearAnalysis() {
    _lastAnalysis = null;
    _error = null;
    notifyListeners();
  }
}
