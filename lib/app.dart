import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/router.dart';

class PaperlyApp extends StatelessWidget {
  const PaperlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Paperly',
      theme: buildTheme(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
