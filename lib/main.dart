import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/services/notification_services.dart';
import 'package:acadobs/core/services/session_manager.dart';
import 'package:acadobs/core/theme/theme.dart';
import 'package:acadobs/core/utils/providers/providers.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    await NotificationServices().initNotification();
  }

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

              child: Builder(
                builder: (context) {
                  final sessionManager = SessionManager(
                    router: appRouter,
                  );
                  ApiServices.initialize(sessionManager);
                  return MaterialApp.router(
                    title: 'Acadobs',
                    debugShowCheckedModeBanner: false,
                    routerConfig: appRouter,
                    theme: AppTheme.lightTheme,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}