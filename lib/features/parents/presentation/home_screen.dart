import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text("ABC School",style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),)
                          // Image.asset("assets/school.jpg"),
                        ],
                      ),
                    ),
                  ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text("Hi Parent",style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),)),
                  Positioned(
                    // top: 16,
                    right: 16,
                    bottom: 16,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage("assets/school.jpg"),
                  ))
              ],
            )
          ],
        ),
      ),
    );
  }
}