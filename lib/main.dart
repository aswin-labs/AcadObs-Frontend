import 'package:acadobs/core/services/notification_services.dart';
import 'package:acadobs/core/theme/theme.dart';
import 'package:acadobs/core/utils/providers/providers.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationServices().initNotification();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return OrientationBuilder(
          builder: (context, orientation) {
            Responsive().init(constraints, orientation);
            return MultiProvider(
              providers: getProviders(),
              child: MaterialApp.router(
                title: 'Acadobs',
                debugShowCheckedModeBanner: false,
                routerConfig: appRouter,
                theme: AppTheme.lightTheme,
              ),
            );
          },
        );
      },
    );
  }
}
