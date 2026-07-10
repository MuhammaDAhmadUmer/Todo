import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_practice/Provider/user.dart';
import 'package:api_practice/services/auth.dart';
import 'package:api_practice/utils/app_theme.dart';
import 'package:api_practice/views/home.dart';
import 'package:api_practice/views/login.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSession());
  }

  Future<void> _checkSession() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final hasToken = await userProvider.loadToken();

    Widget destination = const LoginView();

    if (hasToken) {
      try {
        final token = userProvider.getToken()!;
        final profile = await AuthServices().getProfile(token);
        userProvider.setUser(profile);
        destination = const HomeView();
      } catch (_) {
        // Saved token is invalid/expired — fall back to login.
        await userProvider.logout();
        destination = const LoginView();
      }
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary, size: 56),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
