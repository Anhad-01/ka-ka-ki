import 'package:flutter/material.dart';
import 'routes.dart';
import 'theme.dart';

/// Root widget of the ka-kā-ki app.
class KaKaKiApp extends StatelessWidget {
  const KaKaKiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ka-kā-ki',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
