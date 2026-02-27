import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aa_doudizhu/core/theme.dart';
import 'package:aa_doudizhu/router/app_router.dart';
import 'package:aa_doudizhu/data/services/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore().init();
  runApp(const AAApp());
}

class AAApp extends StatelessWidget {
  const AAApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'AA斗地主 - AlleyAce',
        theme: gothicTheme(),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/',
      ),
    );
  }
}
