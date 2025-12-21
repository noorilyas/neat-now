import 'package:flutter/material.dart';
import 'dart:io';

class EditProfileViewModel extends ChangeNotifier {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onSave;

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController bioController;

  // Store original values
  late String _originalName;
  late String _originalPhone;
  late String _originalBio;

  File? _newImage;
  bool _isSaving = false;
  String? _errorMessage;
  bool _imageUploading = false;
  double _uploadProgress = 0.0;

  EditProfileViewModel({
    required this.userData,
    required this.onSave,
  }) {
    // Initialize with original values
    _originalName = userData['name'] ?? '';
    _originalPhone = userData['phone'] ?? '';
    _originalBio = userData['bio'] ?? '';

    nameController = TextEditingController(text: _originalName);
    phoneController = TextEditingController(text: _originalPhone);
    bioController = TextEditingController(text: _originalBio);

    // Add listeners to detect changes
    nameController.addListener(_onFieldChanged);
    phoneController.addListener(_onFieldChanged);
    bioController.addListener(_onFieldChanged);
  }

  // Notify when any field changes
  void _onFieldChanged() {
    notifyListeners();
  }

  // Getters
  File? get newImage => _newImage;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get imageUploading => _imageUploading;
  double get uploadProgress => _uploadProgress;
  String get currentProfileImage => userData['profileImage'] ?? '';
  String get currentName => userData['name'] ?? 'U';
  String get currentEmail => userData['email'] ?? '';

  // Check if form has changes - MORE RELIABLE
  bool get hasChanges {
    final nameChanged = nameController.text. trim() != _originalName;
    final phoneChanged = phoneController.text.trim() != _originalPhone;
    final bioChanged = bioController.text.trim() != _originalBio;
    final imageChanged = _newImage != null;

    print('DEBUG: Name changed: $nameChanged (${nameController.text.trim()} vs $_originalName)');
    print('DEBUG: Phone changed: $phoneChanged');
    print('DEBUG: Bio changed: $bioChanged');
    print('DEBUG: Image changed: $imageChanged');
    print('DEBUG: Has changes: ${nameChanged || phoneChanged || bioChanged || imageChanged}');

    return nameChanged || phoneChanged || bioChanged || imageChanged;
  }

  // Validation
  bool _validateForm() {
    _errorMessage = null;

    // Validate name
    if (nameController.text.trim().isEmpty) {
      _errorMessage = 'Please enter your name';
      notifyListeners();
      return false;
    }

    if (nameController.text.trim().length < 2) {
      _errorMessage = 'Name must be at least 2 characters';
      notifyListeners();
      return false;
    }

    // Validate phone (if provided)
    if (phoneController.text.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');
      if (!phoneRegex.hasMatch(phoneController.text.trim())) {
        _errorMessage = 'Please enter a valid phone number';
        notifyListeners();
        return false;
      }
    }

    // Validate bio length
    if (bioController.text.trim().length > 500) {
      _errorMessage = 'Bio must be less than 500 characters';
      notifyListeners();
      return false;
    }

    return true;
  }

  // Set new image
  void setNewImage(File? image) {
    _newImage = image;
    print('DEBUG: Image set, hasChanges should be true');
    notifyListeners();
  }

  // Remove new image
  void removeNewImage() {
    _newImage = null;
    notifyListeners();
  }

  // Upload image to server/storage
  Future<String? > _uploadImage() async {
    if (_newImage == null) return null;

    try {
      _imageUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(const Duration(milliseconds: 100));
        _uploadProgress = i / 100;
        notifyListeners();
      }

      // Mock uploaded URL - replace with actual upload response
      final uploadedUrl = 'https://example.com/uploads/${DateTime.now().millisecondsSinceEpoch}. jpg';

      _imageUploading = false;
      notifyListeners();

      return uploadedUrl;
    } catch (e) {
      _imageUploading = false;
      _errorMessage = 'Failed to upload image: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Save profile changes
  Future<bool> save() async {
    // Clear previous errors
    _errorMessage = null;
    notifyListeners();

    // Validate form
    if (!_validateForm()) {
      return false;
    }

    // Check if there are any changes
    if (!hasChanges) {
      _errorMessage = 'No changes to save';
      notifyListeners();
      return false;
    }

    // Start saving
    _isSaving = true;
    notifyListeners();

    try {
      // Upload image if new image is selected
      String? uploadedImageUrl;
      if (_newImage != null) {
        uploadedImageUrl = await _uploadImage();
        if (uploadedImageUrl == null && _imageUploading == false) {
          // Upload failed
          _isSaving = false;
          notifyListeners();
          return false;
        }
      }

      // Prepare updated data
      final updatedData = {
        'name': nameController.text.trim(),
        'phone': phoneController. text.trim(),
        'bio': bioController.text.trim(),
        if (uploadedImageUrl != null) 'profileImage': uploadedImageUrl,
      };

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1000));

      // Call save callback with updated data
      onSave(updatedData);

      _isSaving = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'Failed to save profile: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Reset form to original values
  void reset() {
    nameController.text = _originalName;
    phoneController.text = _originalPhone;
    bioController.text = _originalBio;
    _newImage = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    nameController.removeListener(_onFieldChanged);
    phoneController. removeListener(_onFieldChanged);
    bioController.removeListener(_onFieldChanged);

    nameController.dispose();
    phoneController.dispose();
    bioController. dispose();
    super.dispose();
  }
}