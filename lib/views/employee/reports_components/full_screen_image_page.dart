import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/reports_tab_models.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';


class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final EmployeeResponsiveData responsive;

  const FullScreenImagePage({
    super.key,
    required this. imageUrl,
    required this. responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator. pop(context);
          },
          child: Container(
            margin: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: Colors.black. withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: r.iconSize(22),
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 5.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress. expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          :  null,
                      color: ReportsDesign.primaryTeal,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      size: 80,
                      color: Colors.white. withOpacity(0.5),
                    ),
                    SizedBox(height: r. padding),
                    Text(
                      'Failed to load image',
                      style: GoogleFonts. inter(
                        color: Colors.white. withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}