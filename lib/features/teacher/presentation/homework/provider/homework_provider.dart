import 'package:flutter/material.dart';

class HomeworkProvider extends ChangeNotifier{
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = true;
  bool get isLoadingTwo => _isLoadingTwo;
}