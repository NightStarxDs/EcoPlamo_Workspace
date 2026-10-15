import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/warga/warga_dashboard.dart';
import 'screens/tes_koneksi.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const EcoPlamoApp());
}

class EcoPlamoApp extends StatelessWidget {
  const EcoPlamoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Plamo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const WargaDashboard(),
        '/warga-dashboard': (context) => const WargaDashboard(),
        '/tes-koneksi': (context) => const TesKoneksiScreen(),
      },
    );
  }
}
