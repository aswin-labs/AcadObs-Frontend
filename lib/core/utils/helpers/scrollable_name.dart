import 'package:flutter/material.dart';

class ScrollableName extends StatefulWidget {
  final String studentName;
  const ScrollableName({super.key, required this.studentName});

  @override
  State<ScrollableName> createState() => _ScrollableNameState();
}

class _ScrollableNameState extends State<ScrollableName> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Animate to the end after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: Text(
          widget.studentName,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
