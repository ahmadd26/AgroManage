import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgroManageApp());
}

class AgroManageApp extends StatefulWidget {
  const AgroManageApp({super.key});

  @override
  State<AgroManageApp> createState() => _AgroManageAppState();
}

class _AgroManageAppState extends State<AgroManageApp> {
  final AppState _appState = AppState();
  bool _showSplash = true;
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'AgroManage – Kisan Agro Center',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _appState.themeMode,
          home: _showSplash
              ? SplashScreen(
                  onFinish: () {
                    setState(() => _showSplash = false);
                  },
                )
              : (_isAuthenticated
                  ? MainShell(
                      state: _appState,
                      onLogout: () {
                        setState(() => _isAuthenticated = false);
                      },
                    )
                  : LoginScreen(
                      state: _appState,
                      onLoginSuccess: () {
                        setState(() => _isAuthenticated = true);
                      },
                    )),
        );
      },
    );
  }
}
