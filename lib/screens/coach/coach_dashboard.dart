import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../login/login_screen.dart';

import '../../core/app_colors.dart';

import 'player_details_screen.dart';
import 'attendance_screen.dart';
import 'fees_screen.dart';
import 'competition_screen.dart';
import 'salary_screen.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  Widget dashboardCard({
    required Color color,
    required String image,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Container(
          height: 125,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [

              const SizedBox(width: 14),

              Image.asset(
                image,
                width: 72,
                height: 72,

                // These files are up to 1254px square but never drawn
                // larger than 72. Without this they are decoded at full
                // size, which is slow and holds megabytes per icon.
                cacheWidth: 216,
                cacheHeight: 216,
              ),

              const SizedBox(width: 18),

              Container(
                width: 2,
                height: 55,
                color: AppColors.primary.withOpacity(.35),
              ),

              const SizedBox(width: 14),

              Expanded(
                flex: 3,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const Icon(
                Icons.chevron_right,
                size: 36,
                color: AppColors.primary,
              ),

              const SizedBox(width: 18),

            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(

        backgroundColor: AppColors.primary,

        elevation: 0,

        centerTitle: true,

        title: const Text(
          "Coach Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () async {

              final prefs =
              await SharedPreferences.getInstance();

              await prefs.clear();

              if (context.mounted) {

                Navigator.pushAndRemoveUntil(

                  context,

                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),

                      (route) => false,

                );

              }

            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),

          ),

        ],

      ),

      body: Stack(

        children: [

          /// Purple Circle
          Positioned(
            top: -90,
            left: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xff8B7AA8),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// Peach Circle
          Positioned(
            bottom: -90,
            right: -90,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Color(0xffF0C38E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(

            child: SingleChildScrollView(

              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 20,
              ),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  /// Registration Card

                  Container(

                    width: double.infinity,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 24,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius: BorderRadius.circular(28),

                      boxShadow: const [

                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),

                      ],

                    ),

                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        const Text(

                          "Player Registration Link",

                          style: TextStyle(

                            color: AppColors.primary,

                            fontSize: 18,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 12),

                        Row(

                          children: [

                            Expanded(

                              child: InkWell(

                                onTap: () async {

                                  final Uri uri = Uri.parse(
                                    "https://forms.gle/RCM8wLr92T6n9jBN6",
                                  );

                                  await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  );

                                },

                                child: const Text(
                                  "Open Registration Form",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),

                              ),

                            ),

                            IconButton(

                              onPressed: () {

                                Share.share(

                                  "Join VYK Runners Registration Form\n\n"
                                      "https://forms.gle/RCM8wLr92T6n9jBN6",

                                );

                              },

                              icon: const Icon(

                                Icons.share,

                                color: Color(0xffF0C38E),

                              ),

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                  const SizedBox(height: 32),

                  dashboardCard(
                    color: const Color(0xffE9E3F6),
                    image: "assets/images/playerdetails_logo.jpeg",
                    title: "Player Details",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PlayerDetailsScreen(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    color: const Color(0xffFFF1D9),
                    image: "assets/images/attendance_logo.jpeg",
                    title: "Attendance",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceScreen(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    color: const Color(0xffFDE4E0),
                    image: "assets/images/fees_logo.jpeg",
                    title: "Fees",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeesScreen(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    color: const Color(0xffDCEEF7),
                    image: "assets/images/competitions_logo.jpeg",
                    title: "Competitions",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompetitionScreen(),
                        ),
                      );
                    },
                  ),

                  dashboardCard(
                    color: const Color(0xffDDF7E5),
                    image: "assets/images/salary_logo.png",
                    title: "Salary",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SalaryScreen(),
                        ),
                      );
                    },
                  ),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}