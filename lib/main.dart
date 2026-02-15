import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'data/repositories/auth_repository.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/dashboard/dashboard_viewmodel.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F1A15),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await NotificationService().initialize();

  // Check auth session
  final isLoggedIn = await AuthRepository().isLoggedIn();

  runApp(OrthokoshApp(isLoggedIn: isLoggedIn));
}

class OrthokoshApp extends StatelessWidget {
  final bool isLoggedIn;

  const OrthokoshApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: MaterialApp(
        title: AppStrings.appNameEn,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: isLoggedIn ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }
}
