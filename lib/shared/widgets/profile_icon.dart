import 'package:flutter/material.dart';

class ProfileIcon extends StatelessWidget {
  final String image;
  final VoidCallback? ontap;

  const ProfileIcon({super.key, required this.image, required this.ontap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: GestureDetector(
        onTap: ontap,

        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Profile",

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              CircleAvatar(radius: 15, backgroundImage: AssetImage(image)),
            ],
          ),
        ),
      ),
    );
  }
}
