import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mainscreen.dart';

class Logo extends StatefulWidget {
  const Logo({super.key});

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  void navigateToNextScreen() {
    Timer(Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Mainscreen()),
        (route) => false,
      );
    });
  }

  @override
  void initState() {
   navigateToNextScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/logo.png"),
              Text(
                "FILE",
                style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w600,
                    color: Color(0xff79A5FA),
                  ),
                ),
              ),
              Text(
                "DOWNLOADER",
                style: GoogleFonts.lexend(
                  textStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Color(0xff79A5FA),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
