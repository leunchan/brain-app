import 'package:flutter/material.dart';
import 'package:moonje_mate/screen/chat_screen.dart';
import 'package:moonje_mate/screen/clientinfo_screen.dart';
import 'package:moonje_mate/screen/login_screen.dart';
import 'package:moonje_mate/screen/main_screen.dart';
import 'package:moonje_mate/screen/register_screen.dart';
import 'package:moonje_mate/screen/setting_screen.dart';
import 'package:moonje_mate/screen/splash_screen.dart';
import 'package:moonje_mate/screen/storage_date_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



// init supabase
Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // main 메서드에서 비동기로 데이터를 다루는 상황이 있을 때 반드시 최초에 호출해줘야 되는 메서드
  await Supabase.initialize(
    url: 'https://sdncltappldozngyrnhu.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbmNsdGFwcGxkb3puZ3lybmh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE3MTM2MjAsImV4cCI6MjAyNzI4OTYyMH0.g2UQuA4z6T8_KUoAJve-uI4Ps31cD8ZD0s9vKQtTDx0'
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Gmarket',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        cardColor: Color(0xff70b9db),
      ),
      // 아직 출시가 안된 앱을 테스트 할때는 이걸 끄고 하는게 좋음
      debugShowCheckedModeBanner: false,
      // 앱 최초에 어떤 화면을 쓸것인가
      initialRoute: '/',
      // 각 페이지 라우트
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/main': (context) => MainScreen(),
        '/chat': (context) => ChatScreen(),
        '/setting': (context) => SettingScreen(),
        '/storage': (context) => StorageScreen(),
        '/client': (context) => ClientInfoScreen(),
      },
    );
  }
}
