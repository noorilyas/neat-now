import 'package:flutter/material.dart';
import 'package:neat_now/screens/login_screen.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      // Initialize video player
      _videoController = VideoPlayerController.asset('assets/videos/fyp_video.mp4');

      await _videoController.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });

        _videoController.setVolume(0.0); // Muted - change to 1.0 for sound
        _videoController.play();

        print('Video initialized successfully');
        print('Video duration: ${_videoController.value.duration}');

        // Listen for video completion
        _videoController.addListener(() {
          if (_videoController.value.position >= _videoController.value.duration) {
            _navigateToLogin();
          }
        });
      }
    } catch (error) {
      print('ERROR initializing video: $error');
      print('Make sure the video file exists at: assets/videos/fyp_video.mp4');

      // Wait 3 seconds then navigate anyway
      await Future.delayed(const Duration(seconds: 3));
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isVideoInitialized
            ? SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController.value.size.width,
              height: _videoController.value.size.height,
              child: VideoPlayer(_videoController),
            ),
          ),
        )
            : Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A3D2C),
                const Color(0xFF1B5E20),
                const Color(0xFF2E7D32),
                const Color(0xFF388E3C),
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}