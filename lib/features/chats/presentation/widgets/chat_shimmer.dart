import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ChatShimmer extends StatelessWidget {
  const ChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      padding: const EdgeInsets.all(15),
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder:
          (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey.shade300),
          ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Row(
            children: [
              // profile circle
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 12),

              // lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: MediaQuery.of(context).size.width * 0.5,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
