import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/dio_api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/auth_cubit.dart';
import 'cubits/movie_cubit.dart';
import 'cubits/rental_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env file loaded successfully");
  } catch (e) {
    print("❌ .env file not found: $e");
    print("Will use compile-time environment variables instead");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    String apiKey = '';
    
    if (dotenv.isInitialized && 
        (dotenv.env['TMDB_API_KEY'] ?? '').trim().isNotEmpty) {
      apiKey = dotenv.env['TMDB_API_KEY']!.trim();
      DioApiClient.instance.initializeFromDotenv();
    } else {
      apiKey = const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');
      DioApiClient.instance.initialize(apiKey);
    }
    
    if (apiKey.isEmpty) {
      print("NO API KEY FOUND!");
    } else {
      print("API key loaded: ${apiKey.substring(0, 8)}...");
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit()),
        BlocProvider(
          create: (_) => MovieCubit(client: DioApiClient.instance)
            ..fetchMovies(),
        ),
        BlocProvider(create: (_) => RentalCubit()..loadRentals()),
      ],
      child: MaterialApp(
        title: 'Movie Rental',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6B46C1),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B46C1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
            ),
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}