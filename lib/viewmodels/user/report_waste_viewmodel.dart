import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

import 'package:neat_now/models/user/search_result_model.dart';
import 'package:neat_now/models/user/waste_report_data_model.dart';

class ReportWasteViewModel extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final String?  userId;

  // State
  int _currentStep = 0;
  XFile? _capturedImageFile;
  ImageSource?  _imageSource;
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  String _description = '';
  DateTime? _captureTimestamp;

  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  bool _showLocationPicker = false;
  bool _showAIVerification = false;
  bool?  _aiVerificationResult;
  bool _isSearching = false;
  bool _isDraggingMap = false;

  List<SearchResultModel> _searchResults = [];
  Timer? _searchDebounce;

  // Constants
  final List<String> steps = ['Capture', 'Location', 'Review'];
  final LatLng defaultLocation = const LatLng(31.5204, 74.3587); // Lahore

  ReportWasteViewModel({this.userId});

  // Getters
  int get currentStep => _currentStep;
  XFile? get capturedImageFile => _capturedImageFile;
  ImageSource? get imageSource => _imageSource;
  LatLng? get selectedLocation => _selectedLocation;
  String get selectedAddress => _selectedAddress;
  String get description => _description;
  DateTime? get captureTimestamp => _captureTimestamp;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get isSubmitting => _isSubmitting;
  bool get showLocationPicker => _showLocationPicker;
  bool get showAIVerification => _showAIVerification;
  bool?  get aiVerificationResult => _aiVerificationResult;
  bool get isSearching => _isSearching;
  bool get isDraggingMap => _isDraggingMap;
  List<SearchResultModel> get searchResults => _searchResults;

  // Can proceed to next step
  bool canProceed() {
    switch (_currentStep) {
      case 0: // Capture step
        return _capturedImageFile != null;
      case 1: // Location step
        return _selectedLocation != null;
      case 2: // Review step
        return true;
      default:
        return false;
    }
  }

  // Navigation
  void nextStep() {
    if (_currentStep < steps.length - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Set description
  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  // Image capture
  Future<bool> captureImage(ImageSource source) async {
    try {
      final image = await _imagePicker. pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        _capturedImageFile = image;
        _captureTimestamp = DateTime.now();
        _imageSource = source;
        notifyListeners();

        if (source == ImageSource.camera) {
          await fetchCurrentLocation();
        } else {
          openLocationPicker();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return false;
    }
  }

  // Clear image
  void clearImage() {
    _capturedImageFile = null;
    _selectedLocation = null;
    _selectedAddress = '';
    _imageSource = null;
    notifyListeners();
  }

  // Location management
  void openLocationPicker() {
    _showLocationPicker = true;
    notifyListeners();
  }

  void closeLocationPicker() {
    _showLocationPicker = false;
    notifyListeners();
  }

  void confirmLocation() {
    if (_selectedLocation != null) {
      closeLocationPicker();
    }
  }

  // Fetch current GPS location
  Future<bool> fetchCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission. denied) {
          _isLoadingLocation = false;
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLoadingLocation = false;
        notifyListeners();
        return false;
      }

      final position = await Geolocator. getCurrentPosition(
        desiredAccuracy: LocationAccuracy. high,
        timeLimit: const Duration(seconds: 15),
      );

      final location = LatLng(position.latitude, position.longitude);
      await updateLocationAndAddress(location);
      return true;
    } catch (e) {
      debugPrint('Error fetching location:  $e');
      _isLoadingLocation = false;
      notifyListeners();
      return false;
    }
  }

  // Update location and fetch address
  Future<void> updateLocationAndAddress(LatLng location) async {
    _selectedLocation = location;
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final addressParts = <String>[];

        if (p.street != null && p.street!.isNotEmpty) addressParts.add(p.street!);
        if (p.subLocality != null && p.subLocality!.isNotEmpty) {
          addressParts.add(p.subLocality!);
        }
        if (p. locality != null && p.locality!. isNotEmpty) {
          addressParts.add(p.locality!);
        }
        if (p.subAdministrativeArea != null &&
            p.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(p.subAdministrativeArea!);
        }
        if (p.country != null && p.country!. isNotEmpty) addressParts.add(p.country!);

        final address = addressParts.join(', ');
        _selectedAddress = address. isNotEmpty ? address : 'Unknown location';
      } else {
        _selectedAddress =
        '${location.latitude. toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      }
    } catch (e) {
      _selectedAddress =
      '${location.latitude. toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  // Map dragging state
  void setMapDragging(bool dragging) {
    _isDraggingMap = dragging;
    notifyListeners();
  }

  // Search location
  void searchLocation(String query) {
    _searchDebounce?.cancel();

    if (query.length < 3) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      _isSearching = true;
      notifyListeners();

      try {
        final locations = await locationFromAddress(query);
        final results = <SearchResultModel>[];

        for (final location in locations. take(5)) {
          try {
            final placemarks = await placemarkFromCoordinates(
              location. latitude,
              location.longitude,
            );
            if (placemarks.isNotEmpty) {
              final p = placemarks.first;
              final addressParts = <String>[];

              if (p. street != null && p.street! .isNotEmpty) {
                addressParts.add(p.street!);
              }
              if (p.subLocality != null && p.subLocality!.isNotEmpty) {
                addressParts.add(p.subLocality!);
              }
              if (p. locality != null && p.locality! .isNotEmpty) {
                addressParts.add(p. locality!);
              }
              if (p.country != null && p.country!. isNotEmpty) {
                addressParts.add(p.country!);
              }

              results.add(SearchResultModel(
                address: addressParts.join(', '),
                location:  LatLng(location.latitude, location.longitude),
              ));
            }
          } catch (_) {}
        }

        _searchResults = results;
      } catch (_) {
        _searchResults = [];
      } finally {
        _isSearching = false;
        notifyListeners();
      }
    });
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Submit report with AI verification
  Future<WasteReportDataModel? > submitReport() async {
    _isSubmitting = true;
    _showAIVerification = true;
    notifyListeners();

    // Simulate AI verification
    await Future.delayed(const Duration(milliseconds: 2500));

    // Simulate AI detection (85% success rate)
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    final wasteDetected = random < 85;

    _aiVerificationResult = wasteDetected;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (wasteDetected) {
      final reportData = WasteReportDataModel(
        imagePath: _capturedImageFile! .path,
        latitude: _selectedLocation?. latitude,
        longitude: _selectedLocation?. longitude,
        address: _selectedAddress,
        wasteType:  'General Waste',
        description: _description,
        timestamp: _captureTimestamp?.toIso8601String(),
        status: 'pending',
        userId: userId,
        imageSource: _imageSource == ImageSource.camera ? 'camera' : 'gallery',
      );

      return reportData;
    } else {
      _isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  // Retry with new image
  void retryWithNewImage() {
    _showAIVerification = false;
    _aiVerificationResult = null;
    _capturedImageFile = null;
    _selectedLocation = null;
    _selectedAddress = '';
    _description = '';
    _imageSource = null;
    _currentStep = 0;
    _isSubmitting = false;
    notifyListeners();
  }

  // Format timestamp
  String formatTimestamp(DateTime timestamp) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year} at ${timestamp.hour. toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}