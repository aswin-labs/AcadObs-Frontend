import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                  begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                  )
                ),
                child: Image.asset("assets/school.jpg"),
                )
            ],
          )
        ],
      ),
    );
  }
}