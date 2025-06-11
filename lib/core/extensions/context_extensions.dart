import 'package:flutter/material.dart';

/// Access theme, colors, and text styles easily
extension ThemeContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ThemeData get theme => Theme.of(this);
}

/// Screen size & MediaQuery helpers
extension MediaQueryContext on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenWidth => MediaQuery.of(this).size.width;
  Orientation get orientation => MediaQuery.of(this).orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
}

/// SafeArea insets
extension SafeAreaContext on BuildContext {
  double get topInset => MediaQuery.of(this).padding.top;
  double get bottomInset => MediaQuery.of(this).padding.bottom;
  double get statusBarHeight => topInset;
  double get navigationBarHeight => bottomInset;
}

/// Common padding styles
extension PaddingContext on BuildContext {
  EdgeInsets get paddingXS => const EdgeInsets.all(4);
  EdgeInsets get paddingS => const EdgeInsets.all(8);
  EdgeInsets get paddingM => const EdgeInsets.all(16);
  EdgeInsets get paddingL => const EdgeInsets.all(24);
  EdgeInsets get paddingXL => const EdgeInsets.all(32);

  EdgeInsets get paddingHorizontal =>
      const EdgeInsets.symmetric(horizontal: 16);
  EdgeInsets get paddingHorizontalLarge =>
      const EdgeInsets.symmetric(horizontal: 32);

      EdgeInsets get paddingVerticalXS => const EdgeInsets.symmetric(vertical: 4);
  EdgeInsets get paddingVertical => const EdgeInsets.symmetric(vertical: 16);
  EdgeInsets get paddingTopSafe => EdgeInsets.only(top: topInset + 16);
  EdgeInsets get paddingBottomSafe => EdgeInsets.only(bottom: bottomInset + 16);
}

/// AppBar height helper (default is 56)
extension AppBarContext on BuildContext {
  double get appBarHeight => kToolbarHeight + topInset;
}
