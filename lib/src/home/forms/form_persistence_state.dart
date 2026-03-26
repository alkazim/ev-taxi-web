import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPersistenceState extends ChangeNotifier {
  Map<String, String> _franchiseData = {};
  Map<String, String> _driverData = {};

  // To track the current step in multi-step forms
  int _driverCurrentStep = 0;

  Map<String, String> get franchiseData => _franchiseData;
  Map<String, String> get driverData => _driverData;
  int get driverCurrentStep => _driverCurrentStep;

  FormPersistenceState() {
    _loadFromDisk();
  }

  void updateFranchiseField(String key, String value) {
    if (_franchiseData[key] == value) return;
    _franchiseData[key] = value;
    _saveToDisk();
    notifyListeners();
  }

  void updateDriverField(String key, String value) {
    if (_driverData[key] == value) return;
    _driverData[key] = value;
    _saveToDisk();
    notifyListeners();
  }

  void setDriverStep(int step) {
    if (_driverCurrentStep == step) return;
    _driverCurrentStep = step;
    _saveToDisk();
    notifyListeners();
  }

  void clearFranchise() {
    _franchiseData = {};
    _saveToDisk();
    notifyListeners();
  }

  void clearDriver() {
    _driverData = {};
    _driverCurrentStep = 0;
    _saveToDisk();
    notifyListeners();
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'persisted_franchise_data',
      jsonEncode(_franchiseData),
    );
    await prefs.setString('persisted_driver_data', jsonEncode(_driverData));
    await prefs.setInt('persisted_driver_step', _driverCurrentStep);
  }

  Future<void> _loadFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final franchiseJson = prefs.getString('persisted_franchise_data');
      if (franchiseJson != null) {
        _franchiseData = Map<String, String>.from(jsonDecode(franchiseJson));
      }

      final driverJson = prefs.getString('persisted_driver_data');
      if (driverJson != null) {
        _driverData = Map<String, String>.from(jsonDecode(driverJson));
      }

      _driverCurrentStep = prefs.getInt('persisted_driver_step') ?? 0;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading persisted form data: $e');
    }
  }
}
