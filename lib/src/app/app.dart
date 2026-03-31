import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class DotesApp extends StatelessWidget {
  const DotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dotes',
      theme: AppTheme.dark(),
      initialRoute: AppRoutes.importPlayer,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
