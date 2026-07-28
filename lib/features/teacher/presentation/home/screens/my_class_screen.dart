import 'package:acadobs/features/students/presentation/widgets/student_feature_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';

class MyClassScreen extends StatelessWidget {
  const MyClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'My Class', isBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Text('Class Name'),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StudentFeatureCard(
                    icon: Icons.check_circle_outline,
                    title: "Attendance",
                    color: Colors.green,
                    onTap: () {},
                  ),
                  SizedBox(width: 10),
                  StudentFeatureCard(
                    icon: Icons.edit_note,
                    title: "Marks",
                    color: Colors.brown,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  StudentFeatureCard(
                    icon: Icons.workspace_premium,
                    title: "Achievements",
                    color: Colors.amber,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Students',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(9),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(),
                  itemBuilder: (context, index) {
                    return ProfileTile(
                      name: 'shibu',
                      description: "Roll No: ${10}",
                      onPressed: () {},
                      // () => context.pushNamed(
                      //   RouteConstants.studentDetails,
                      //   extra: StudentDetailParameters(
                      //     forStaff: true,
                      //     studentId: student.id,
                      //   ),
                      // ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
