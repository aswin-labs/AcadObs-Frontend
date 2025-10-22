import 'package:flutter/material.dart';

class CustomButtonContainer extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback ontap;
  final bool isFullWidth;
  final IconData icon;
  final bool isCenterText;

  const CustomButtonContainer({
    super.key,

    required this.text,
    required this.color,
    required this.ontap,
    this.isFullWidth = false,
    this.icon = Icons.dashboard_customize_outlined,
    this.isCenterText = false,
  });

  @override
  State<CustomButtonContainer> createState() => _CustomButtonContainerState();
}

class _CustomButtonContainerState extends State<CustomButtonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.ontap();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color, widget.color.withAlpha(220)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.ontap,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withAlpha(50),
              highlightColor: Colors.white.withAlpha(30),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          widget.isCenterText
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.check_circle_outline,
                            color: Colors.white.withAlpha(150),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          widget.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.white.withAlpha(200),
                          size: 16,
                        ),
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     // const Text(
                    //     //   'VIEW',
                    //     //   style: TextStyle(
                    //     //     color: Colors.black,
                    //     //     fontSize: 14,
                    //     //     fontWeight: FontWeight.w600,
                    //     //     letterSpacing: 0.5,
                    //     //   ),
                    //     // ),
                    //     // const SizedBox(width: 8),

                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:acadobs/core/utils/responsive.dart';
// import 'package:flutter/material.dart';

// class CustomButtonContainer extends StatelessWidget {
//   final Color color;
//   final String text;
//   final IconData icon;
//   final VoidCallback ontap;
//   final bool isCenterText;

//   const CustomButtonContainer({
//     super.key,
//     required this.color,
//     required this.text,
//     this.icon = Icons.dashboard_customize_outlined,
//     required this.ontap,
//     this.isCenterText = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: ontap,
//       child: Container(
//         padding: EdgeInsets.all(Responsive.height * 3),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisAlignment:
//               isCenterText ? MainAxisAlignment.center : MainAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: Responsive.width * 3),
//               child: Icon(
//                 icon,
//                 color: Colors.white,
//               ),
//             ),
//             Text(
//               text,
//               style: const TextStyle(color: Colors.white, fontSize: 18),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
