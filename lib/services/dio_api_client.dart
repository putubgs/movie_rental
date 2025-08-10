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
    
    if (raw.isEmpty) {
      print("ERROR: Cannot initialize with empty API key!");
      throw ArgumentError('API key cannot be empty');
    }
    
    if (_initialized && raw == _apiKey) {
      print("API client already initialized with same key");
      return;
    }
    
    final lower = raw.toLowerCase();
    _apiKey = raw;
    
    if (lower.startsWith('bearer ')) {
      _isBearer = true;
    } else if (lower.startsWith('ey')) {
      _isBearer = true;
      _apiKey = 'Bearer $raw';
    } else {
      _isBearer = false;
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
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!_isBearer && options.queryParameters.containsKey('api_key')) {
            final key = options.queryParameters['api_key'] as String;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          print("Error message: ${error.message}");
          handler.next(error);
        },
      ),
    );
    
    _initialized = true;
  }

  void initializeFromDotenv() {
    final token = (dotenv.env['TMDB_API_KEY'] ?? '').trim();
    if (token.isEmpty) {
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