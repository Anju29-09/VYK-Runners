import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_colors.dart';
import '../login/login_screen.dart';

import 'player_attendance_screen.dart';
import 'player_fees_screen.dart';
import 'player_competition_screen.dart';

class PlayerDashboard extends StatelessWidget {
  final String playerName;
  final String playerEmail;

  const PlayerDashboard({
    super.key,
    required this.playerName,
    required this.playerEmail,
  });

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

                // Decoded at roughly the size actually drawn rather than
                // the source file's full resolution.
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

  Future<void> logout(BuildContext context) async {

    final prefs = await SharedPreferences.getInstance();

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
            "Player Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          actions: [

            IconButton(

              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ),

              onPressed: () => logout(context),

            )

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

                children: [

            Align(

              alignment: Alignment.centerLeft,

              child: Text(
                "Welcome,\n$playerName",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),

            ),

            const SizedBox(height: 32),
                  dashboardCard(
                    color: const Color(0xffFFF1D9),
                    image: "assets/images/attendance_logo.jpeg",
                    title: "Attendance",
                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlayerAttendanceScreen(
                            playerName: playerName,
                          ),
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
                          builder: (_) => PlayerFeesScreen(
                            playerName: playerName,
                            playerEmail: playerEmail,
                          ),
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
                          builder: (_) => PlayerCompetitionScreen(
                            playerName: playerName,
                          ),
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