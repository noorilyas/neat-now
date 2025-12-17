import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationService {
  /// Navigate to a location using available map apps
  static Future<NavigationResult> navigateTo({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = label != null ? Uri. encodeComponent(label) : '';

    // List of navigation URLs to try (in order of preference)
    final navigationUrls = [
      // Google Maps navigation (Android)
      _NavOption(
        'Google Maps Navigation',
        Uri.parse('google.navigation:q=$latitude,$longitude&mode=d'),
        requiresExternalApp: true,
      ),
      // Google Maps directions (Universal)
      _NavOption(
        'Google Maps Directions',
        Uri.parse('https://www. google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving'),
        requiresExternalApp: true,
      ),
      // Apple Maps (iOS)
      _NavOption(
        'Apple Maps',
        Uri.parse('maps://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d'),
        requiresExternalApp: true,
      ),
      // Geo URI (Android fallback)
      _NavOption(
        'Geo URI',
        Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)'),
        requiresExternalApp: true,
      ),
      // Browser fallback
      _NavOption(
        'Browser',
        Uri.parse('https://www.google.com/maps/search/? api=1&query=$latitude,$longitude'),
        requiresExternalApp: true,
      ),
    ];

    for (final option in navigationUrls) {
      try {
        final canLaunch = await canLaunchUrl(option. url);
        if (canLaunch) {
          final launched = await launchUrl(
            option.url,
            mode: option.requiresExternalApp
                ? LaunchMode. externalApplication
                : LaunchMode.platformDefault,
          );
          if (launched) {
            return NavigationResult(
              success: true,
              method: option.name,
            );
          }
        }
      } catch (e) {
        debugPrint('Failed to launch ${option.name}: $e');
      }
    }

    return NavigationResult(
      success: false,
      error: 'Could not open any navigation app',
    );
  }

  /// Open location in Google Maps (view only, no navigation)
  static Future<bool> openInGoogleMaps({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('https://www. google.com/maps/search/?api=1&query=$latitude,$longitude');
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  /// Copy coordinates to clipboard
  static Future<void> copyCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    await Clipboard.setData(ClipboardData(text: '$latitude,$longitude'));
  }

  /// Get directions URL for sharing
  static String getDirectionsUrl({
    required double latitude,
    required double longitude,
  }) {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }
}

class _NavOption {
  final String name;
  final Uri url;
  final bool requiresExternalApp;

  _NavOption(this. name, this.url, {this.requiresExternalApp = false});
}

class NavigationResult {
  final bool success;
  final String? method;
  final String? error;

  NavigationResult({
    required this.success,
    this.method,
    this.error,
  });
}