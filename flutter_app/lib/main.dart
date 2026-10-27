import 'package:flutter/material.dart';
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/katalog/katalog_screen.dart';
import 'screens/warga/warga_dashboard.dart';
import 'screens/pengurus/pengurus_dashboard.dart';
import 'screens/dlh/dlh_dashboard.dart';
import 'screens/info/info_screen.dart';
import 'screens/profile/profile_screen.dart';
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
  final String initialRoute;
  const EcoPlamoApp({super.key, this.initialRoute = '/splash'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco Plamo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/register': (context) => const RegisterScreen(),
        '/warga-dashboard': (context) => const WargaDashboard(),
        '/pengurus-dashboard': (context) => const PengurusDashboard(),
        '/dlh-dashboard': (context) => const DlhDashboard(),
        '/home': (context) => const WargaDashboard(), // Fallback for legacy
        '/tes-koneksi': (context) => const TesKoneksiScreen(),
        '/katalog': (context) => const KatalogScreen(),
        '/info': (context) => const InfoScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
