import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class BusRouteCard extends StatelessWidget {
  final String studentName;
  final String routeName;
  final bool isPickup;
  final VoidCallback onTap;
  final bool isLive;

  const BusRouteCard({
    super.key,
    required this.studentName,
    required this.routeName,
    required this.isPickup,
    required this.onTap,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.height * 1.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(Responsive.width * 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color:
                  isLive
                      ? Color.fromARGB(255, 30, 209, 90)
                      : Colors.grey.withAlpha(40),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLive
                  ? Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 30, 209, 90),

                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: Responsive.width * 2),
                      Text(
                        'Live',
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                  : SizedBox.shrink(),

              SizedBox(height: Responsive.height * 1.5),

              /// Student Name
              Text(
                studentName,
                style: context.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: Responsive.height * 1.5),

              /// Route Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF333333),
                    child: Icon(Icons.route_rounded),
                  ),

                  SizedBox(width: Responsive.width * 3),

                  Expanded(
                    child: Text(
                      routeName,
                      style: context.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  /// Pickup / Drop Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.width * 3,
                      vertical: Responsive.height * .7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isPickup
                              ? Colors.green.withAlpha(25)
                              : Colors.blue.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPickup ? Colors.green : Colors.blue,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPickup ? Icons.login_rounded : Icons.logout_rounded,
                          size: 14,
                          color: isPickup ? Colors.green : Colors.blue,
                        ),
                        SizedBox(width: Responsive.width * 1.5),
                        Text(
                          isPickup ? "Pickup" : "Drop",
                          style: context.textTheme.bodySmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isPickup ? Colors.green : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: Responsive.height * 1.5),

              /// Small arrow hint (optional but good UX)
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
