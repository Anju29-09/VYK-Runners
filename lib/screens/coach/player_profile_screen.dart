import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerProfileScreen extends StatelessWidget {

  final Map<String, dynamic> player;

  const PlayerProfileScreen({
    super.key,
    required this.player,
  });

  // ============================================================
  // GET VALUE SAFELY
  // ============================================================

  String getValue(String key) {

    final value = player[key];

    if (value == null) {
      return "";
    }

    return value.toString().trim();

  }

  // ============================================================
  // OPEN DOCUMENT / IMAGE
  // ============================================================

  Future<void> openUrl(
      BuildContext context,
      String url,
      ) async {

    if (url.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Document not available",
          ),
        ),
      );

      return;
    }

    try {

      final uri = Uri.parse(url);

      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!success) {

        throw Exception(
          "Could not open URL",
        );

      }

    } catch (e) {

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to open document",
          ),
        ),
      );

    }

  }

  // ============================================================
  // DETAILS TEXT
  // ============================================================

  String get detailsText {

    return
      "Name : ${getValue("Players full name")}"
          "\n\n"
          "Mother Name : ${getValue("Mother's name")}"
          "\n\n"
          "Father Name : ${getValue("Father's name")}"
          "\n\n"
          "Age : ${getValue("Age")}"
          "\n\n"
          "Address : ${getValue(" Home address")}"
          "\n\n"
          "Contact : ${getValue("Contact Number")}"
          "\n\n"
          "Branch : ${getValue("Select the branch where you Practice.")}"
          "\n\n"
          "Group : ${getValue("Select which group you represent. ")}";

  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    final passportUrl =
    getValue("Passport size photo");

    final aadhaarUrl =
    getValue("Adhaar Card Photo");

    return Scaffold(

      backgroundColor:
      const Color(0xffF8F1E9),

      appBar: AppBar(

        title: const Text(
          "Player Profile",
        ),

        backgroundColor:
        const Color(0xff312C51),

        foregroundColor:
        Colors.white,

      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.stretch,

            children: [

              // ==================================================
              // PLAYER NAME
              // ==================================================

              Text(

                getValue(
                  "Players full name",
                ),

                textAlign:
                TextAlign.center,

                style: const TextStyle(

                  fontSize: 28,

                  fontWeight:
                  FontWeight.w900,

                  color:
                  Color(0xff312C51),

                ),

              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // DETAILS CARD
              // ==================================================

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets.all(22),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: const [

                    BoxShadow(

                      color:
                      Colors.black12,

                      blurRadius:
                      10,

                      offset:
                      Offset(0, 5),

                    ),

                  ],

                ),

                child: Text(

                  detailsText,

                  style: const TextStyle(

                    fontSize: 17,

                    height: 1.7,

                    color:
                    Color(0xff312C51),

                  ),

                ),

              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // PASSPORT PHOTO
              // ==================================================

              SizedBox(

                height: 55,

                child: ElevatedButton.icon(

                  onPressed:
                  passportUrl.isEmpty
                      ? null
                      : () {

                    openUrl(
                      context,
                      passportUrl,
                    );

                  },

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xff312C51),

                    disabledBackgroundColor:
                    Colors.grey.shade400,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),

                    ),

                    elevation:
                    8,

                  ),

                  icon:
                  const Icon(
                    Icons.photo,
                    color: Colors.white,
                  ),

                  label:
                  Text(

                    passportUrl.isEmpty
                        ? "Passport Photo Not Available"
                        : "View Passport Photo",

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),

              ),

              const SizedBox(
                height: 15,
              ),

              // ==================================================
              // AADHAAR CARD
              // ==================================================

              SizedBox(

                height: 55,

                child: ElevatedButton.icon(

                  onPressed:
                  aadhaarUrl.isEmpty
                      ? null
                      : () {

                    openUrl(
                      context,
                      aadhaarUrl,
                    );

                  },

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xff312C51),

                    disabledBackgroundColor:
                    Colors.grey.shade400,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),

                    ),

                    elevation:
                    8,

                  ),

                  icon:
                  const Icon(
                    Icons.badge,
                    color: Colors.white,
                  ),

                  label:
                  Text(

                    aadhaarUrl.isEmpty
                        ? "Aadhaar Card Not Available"
                        : "View Aadhaar Card",

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),

              ),

              const SizedBox(
                height: 50,
              ),

            ],

          ),

        ),

      ),

    );

  }

}