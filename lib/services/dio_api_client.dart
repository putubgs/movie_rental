import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioApiClient {
  DioApiClient._internal();
  static final DioApiClient instance = DioApiClient._internal();

  late final Dio _dio;
  bool _initialized = false;
  late String _apiKey;
  late bool _isBearer;

  void initialize(String apiKey) {
    final raw = apiKey.trim();
    
    // Validate API key is not empty
    if (raw.isEmpty) {
      print("❌ ERROR: Cannot initialize with empty API key!");
      throw ArgumentError('API key cannot be empty');
    }
    
    // Re-init if key changed (helps after hot-reload/hot-restart)
    if (_initialized && raw == _apiKey) {
      print("✅ API client already initialized with same key");
      return;
    }
    
    final lower = raw.toLowerCase();
    _apiKey = raw;
    
    // Accept either full "Bearer <token>" or raw v4 token starting with 'ey'
    if (lower.startsWith('bearer ')) {
      _isBearer = true;
      print("🔑 Using Bearer token authentication");
    } else if (lower.startsWith('ey')) {
      _isBearer = true;
      _apiKey = 'Bearer $raw';
      print("🔑 Converting to Bearer token authentication");
    } else {
      _isBearer = false; // assume v3 api key
      print("🔑 Using v3 API key authentication");
    }
    
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.themoviedb.org/3/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {
          if (_isBearer) 
            'Authorization': _apiKey.startsWith('Bearer ') ? _apiKey : 'Bearer $_apiKey',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status >= 200 && status < 400,
        receiveDataWhenStatusError: true,
      ),
    );
    
    // Enhanced logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print("🌐 API Request: ${options.method} ${options.path}");
          if (!_isBearer && options.queryParameters.containsKey('api_key')) {
            final key = options.queryParameters['api_key'] as String;
            print("🔑 Using API key: ${key.isNotEmpty ? '${key.substring(0, 8)}...' : 'EMPTY!'}");
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print("✅ API Response: ${response.statusCode} ${response.requestOptions.path}");
          handler.next(response);
        },
        onError: (error, handler) {
          print("❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}");
          print("Error message: ${error.message}");
          handler.next(error);
        },
      ),
    );
    
    _initialized = true;
    print("✅ DioApiClient initialized successfully");
  }

  void initializeFromDotenv() {
    final token = (dotenv.env['TMDB_API_KEY'] ?? '').trim();
    if (token.isEmpty) {
      print("❌ ERROR: TMDB_API_KEY not found in .env file");
      throw ArgumentError('TMDB_API_KEY not found in .env file');
    }
    initialize(token);
  }

  Dio get dio {
    if (!_initialized) {
      throw StateError('DioApiClient not initialized. Call initialize() first.');
    }
    return _dio;
  }
  
  String get apiKey => _apiKey;
  bool get isBearer => _isBearer;
  bool get isInitialized => _initialized;
}