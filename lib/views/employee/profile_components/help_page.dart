import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neat_now/models/employee/profile_models.dart';
import 'package:neat_now/design/profile_design.dart';
import 'package:neat_now/views/employee/responsive_employee_helper.dart';

class HelpPage extends StatelessWidget {
  final EmployeeResponsiveData responsive;

  const HelpPage({
    super.key,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final r = responsive;

    final faqs = [
      FAQItem(
        'How do I complete a task?',
        'Navigate to the task, tap "Complete", take a photo of the cleaned area, and submit.',
      ),
      FAQItem(
        'How is my rating calculated?',
        'Your rating is based on citizen feedback after each completed task.',
      ),
      FAQItem(
        'What are badges?',
        'Badges are achievements you earn for milestones like completing tasks quickly or maintaining high ratings.',
      ),
      FAQItem(
        'How do I update my profile?',
        'Go to Profile > Edit Profile to update your name, email, phone, and photo.',
      ),
      FAQItem(
        'Who do I contact for support?',
        'Reach out to your supervisor or email support@neatnow.com for assistance.',
      ),
    ];

    return Scaffold(
      backgroundColor: ProfileDesign.surfaceLight,
      appBar: AppBar(
        backgroundColor: ProfileDesign.surfacePure,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(r.microPadding),
            decoration:  BoxDecoration(
              color:  ProfileDesign.surfaceLight,
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: ProfileDesign.textPrimary,
              size: r.iconSize(18),
            ),
          ),
        ),
        title: Text(
          'Help & Support',
          style:  GoogleFonts.inter(
            fontSize: r.bodyM,
            fontWeight: FontWeight. w700,
            color: ProfileDesign.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(r.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(r.padding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ProfileDesign.primaryTeal.withOpacity(0.1),
                    ProfileDesign.primaryTealLight.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(r.largeBorderRadius),
                border: Border. all(color: ProfileDesign.primaryTeal. withOpacity(0.2)),
              ),
              child:  Row(
                children: [
                  Container(
                    padding: EdgeInsets. all(r.microPadding),
                    decoration: BoxDecoration(
                      gradient: ProfileDesign.primaryGradient,
                      borderRadius: BorderRadius.circular(r. borderRadius),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: r.iconSize(24),
                    ),
                  ),
                  SizedBox(width:  r.padding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:  CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need Help?',
                          style: GoogleFonts.inter(
                            fontSize: r.bodyS,
                            fontWeight: FontWeight.w700,
                            color: ProfileDesign.primaryTeal,
                          ),
                        ),
                        Text(
                          'We\'re here to assist you',
                          style: GoogleFonts.inter(
                            fontSize: r.captionS,
                            color: ProfileDesign. textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: r.padding),

            // FAQs
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w700,
                color: ProfileDesign.textPrimary,
              ),
            ),
            SizedBox(height: r.microPadding),

            ... faqs.asMap().entries.map((entry) => _buildFAQCard(r, entry.value, entry.key)),

            SizedBox(height:  r.padding),

            // Contact
            Text(
              'Contact Us',
              style: GoogleFonts.inter(
                fontSize: r.bodyS,
                fontWeight: FontWeight.w700,
                color: ProfileDesign. textPrimary,
              ),
            ),
            SizedBox(height: r.microPadding),

            _buildContactCard(
              r,
              Icons.email_rounded,
              'Email',
              'support@neatnow.com',
              ProfileDesign.info,
            ),
            SizedBox(height: r.microPadding),
            _buildContactCard(
              r,
              Icons.phone_rounded,
              'Phone',
              '+1 (555) 123-4567',
              ProfileDesign.success,
            ),

            SizedBox(height: r.safePaddingBottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQCard(EmployeeResponsiveData r, FAQItem faq, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: r.microPadding),
        decoration: BoxDecoration(
          color: ProfileDesign. surfacePure,
          borderRadius:  BorderRadius.circular(r.largeBorderRadius),
          boxShadow: ProfileDesign.softShadow,
        ),
        child: Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: ProfileDesign.primaryTeal.withOpacity(0.05),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets. symmetric(
              horizontal: r.padding,
              vertical: r.nanoPadding,
            ),
            childrenPadding: EdgeInsets.fromLTRB(
              r.padding,
              0,
              r.padding,
              r.padding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:  BorderRadius.circular(r.largeBorderRadius),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(r.largeBorderRadius),
            ),
            title: Text(
              faq.question,
              style: GoogleFonts. inter(
                fontSize: r. bodyS,
                fontWeight:  FontWeight.w600,
                color: ProfileDesign.textPrimary,
              ),
            ),
            iconColor: ProfileDesign.primaryTeal,
            collapsedIconColor: ProfileDesign.textTertiary,
            children: [
              Text(
                faq.answer,
                style: GoogleFonts.inter(
                  fontSize: r.captionM,
                  color: ProfileDesign.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
      EmployeeResponsiveData r,
      IconData icon,
      String label,
      String value,
      Color color,
      ) {
    return Container(
      padding: EdgeInsets.all(r.padding),
      decoration: BoxDecoration(
        color: ProfileDesign.surfacePure,
        borderRadius: BorderRadius. circular(r.largeBorderRadius),
        boxShadow:  ProfileDesign.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(r.microPadding),
            decoration: BoxDecoration(
              color: color. withOpacity(0.1),
              borderRadius: BorderRadius. circular(r.borderRadius),
            ),
            child: Icon(icon, color: color, size:  r.iconSize(20)),
          ),
          SizedBox(width: r.padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:  GoogleFonts.inter(
                    fontSize: r.captionS,
                    color: ProfileDesign.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: r.bodyS,
                    fontWeight: FontWeight.w600,
                    color: ProfileDesign.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: ProfileDesign.textTertiary,
            size: r.iconSize(22),
          ),
        ],
      ),
    );
  }
}