import 'package:flutter/material.dart';

class Responsive {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _blockSizeHorizontal = 0;
  static double _blockSizeVertical = 0;
  static double text = 0;
  static double radius = 0;
  static double height = 0;
  static double width = 0;
  static bool isPortrait = true;
  static bool isMobilePortrait = false;

  void init(BoxConstraints constraints, Orientation orientation) {
    if (orientation == Orientation.portrait) {
      _screenWidth = constraints.maxWidth;
      _screenHeight = constraints.maxHeight;
      isPortrait = true;
      if (_screenWidth < 450) {
        isMobilePortrait = true;
      }
    } else {
      _screenWidth = constraints.maxHeight;
      _screenHeight = constraints.maxWidth;
      isPortrait = false;
      isMobilePortrait = false;
    }

    _blockSizeHorizontal = _screenWidth / 100;
    _blockSizeVertical = _screenHeight / 100;

    text = _blockSizeVertical;
    radius = _blockSizeHorizontal;
    height = _blockSizeVertical;
    width = _blockSizeHorizontal;
  }
}