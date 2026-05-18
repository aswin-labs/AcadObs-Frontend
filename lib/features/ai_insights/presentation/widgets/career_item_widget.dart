import 'package:flutter/material.dart';

class CareerItem {
  final String label;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
 
  const CareerItem({
    required this.label,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
  });
}
 
class SuggestedCareerAreasWidget extends StatelessWidget {
  final List<CareerItem> careers;
  final String heading;
 
  const SuggestedCareerAreasWidget({
    super.key,
    required this.careers,
    this.heading = 'Suggested Career Areas',
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // _SectionHeading(
        //   icon: Icons.radio_button_checked_rounded,
        //   iconColor: const Color(0xFF16A34A),
        //   text: heading,
        // ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(careers.length, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < careers.length - 1 ? 10 : 0),
                child: _CareerCard(item: careers[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}
 
class _CareerCard extends StatelessWidget {
  final CareerItem item;
  const _CareerCard({required this.item});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: item.borderColor, width: 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280).withAlpha(200),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}