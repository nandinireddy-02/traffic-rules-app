import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/grade_aware_home_screen.dart';
import 'services/user_service.dart';
import 'services/quiz_service.dart';
import 'services/grade_aware_quiz_service.dart';
import 'models/user.dart';

void main() {
  runApp(const TrafficRulesKidsApp());
}

class TrafficRulesKidsApp extends StatelessWidget {
  const TrafficRulesKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserService()),
        ChangeNotifierProvider(create: (context) => GradeAwareQuizService()),
        ChangeNotifierProvider<QuizService>(create: (context) => QuizService()),
      ],
      child: MaterialApp(
        title: 'TrafficAce Kids - Grade-wise Learning',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ).copyWith(
            primary: const Color(0xFF6366F1),
            secondary: const Color(0xFF8B5CF6),
            tertiary: const Color(0xFF06B6D4),
            surface: Colors.white,
            error: const Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: const Color(0xFF1E293B),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF1E293B),
            elevation: 0,
            scrolledUnderElevation: 0,
            titleTextStyle: TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: Color(0xFF6366F1),
            unselectedItemColor: Color(0xFF64748B),
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
  home: const MainApp(),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  bool _isInitialized = false;
  bool _showLogin = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    final userService = Provider.of<UserService>(context, listen: false);
    final gradeAwareQuizService = Provider.of<GradeAwareQuizService>(context, listen: false);
    final quizService = Provider.of<QuizService>(context, listen: false);
    
    await userService.initialize();
    await gradeAwareQuizService.initialize();
    await quizService.initialize();
    
    setState(() {
      _isInitialized = true;
      _showLogin = !userService.isLoggedIn;
    });
  }

  void _handleLogin(User user) async {
    final userService = Provider.of<UserService>(context, listen: false);
    await userService.createOrLoginUser(
      name: user.name,
      email: user.email,
      grade: user.grade,
    );
    
    setState(() {
      _showLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade600,
                Colors.purple.shade400,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  '🚦 Loading TrafficAce Kids...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<UserService>(
      builder: (context, userService, child) {
        if (!userService.isLoggedIn || _showLogin) {
          return LoginScreen(onLogin: _handleLogin);
        }
        
        return const GradeAwareHomeScreen();
      },
    );
  }
}