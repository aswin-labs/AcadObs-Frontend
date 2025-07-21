import 'package:acadobs/features/parents/presentation/notices/widgets/notice_card.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: 250,
                  width: double.infinity,
                  child: Image.asset("assets/school.jpg", fit: BoxFit.cover),
                ),
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xCC35C2C1), Color(0xCC00AEF0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "ABC School Academy",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Text(
                    "Hi, Parent",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage("assets/school.jpg"),
                  ),
                ),
              ],
            ),

            ///////////////////
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  CustomButtonContainer(
                    color: Colors.black,
                    text: 'leave request',
                    ontap: () {},
                  ),

                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Children",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProfileTile(name: 'Amal', description: 'aaa Villa'),
                  // SizedBox(height: 2),
                  ProfileTile(name: 'Arun', description: 'aaa Villa'),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        "Notices",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "View",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),

                  NoticeCard(
                    title: 'PTA Meeting Class XI',
                    date: "22-07-2025",
                    icon: Icons.notifications,
                    time: "12:30",
                    onTap: () {},
                  ),
                  NoticeCard(
                    title: 'PTA Meeting Class X',
                    date: "21-07-2025",
                    icon: Icons.notifications,
                    time: "12:30",
                    onTap: () {},
                  ),
                ],
              ),
            ),

            ///////////////
          ],
        ),
      ),
    );
  }
}
