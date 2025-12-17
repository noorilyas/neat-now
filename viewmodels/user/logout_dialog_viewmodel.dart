import 'package:flutter/material.dart';

class LogoutDialogViewModel extends ChangeNotifier {
  final VoidCallback onConfirm;

  bool _isLoggingOut = false;

  LogoutDialogViewModel({required this.onConfirm});

  bool get isLoggingOut => _isLoggingOut;

  Future<void> confirm() async {
    _isLoggingOut = true;
    notifyListeners();

    // Simulate logout process
    await Future.delayed(const Duration(milliseconds: 800));

    onConfirm();
  }
}