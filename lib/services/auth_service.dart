import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'https://ashtana-render.onrender.com';
  static String? _token;

  static String? get token => _token;

  static Map<String, String> getHeaders({bool withAuth = true}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'accept': '*/*',
    };
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    print('🔄 Auth initialized. Token: ${_token != null ? "Exists" : "None"}');
  }

  static Future<void> _saveToken(String newToken) async {
    _token = newToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', newToken);
    print('💾 Token saved: ${newToken.substring(0, 20)}...');
    
    // Also save user info if we have it
    if (_token != null) {
      final payload = decodeTokenPayload(_token!);
      if (payload != null) {
        await prefs.setString('user_payload', jsonEncode(payload));
      }
    }
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_payload');
    print('🗑️ Token cleared');
  }

  // SIGN IN METHOD - Updated for your API
  static Future<Map<String, dynamic>> signIn({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/signin');
    
    final body = jsonEncode({
      'username': username,
      'password': password,
    });

    print('🚀 SIGN IN REQUEST');
    print('URL: $url');
    print('Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': '*/*',
        },
        body: body,
      );

      print('📡 RESPONSE RECEIVED');
      print('Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          print('❌ JSON Parse Error: $e');
          return {'success': false, 'message': 'Invalid response format'};
        }

        print('✅ Login successful!');
        print('Response keys: ${responseData.keys}');

        // **CRITICAL FIX: Your API uses 'jwtToken' not 'token'**
        if (responseData.containsKey('jwtToken')) {
          String token = responseData['jwtToken'].toString();
          print('🔑 Found jwtToken: ${token.substring(0, 30)}...');
          
          // Save the token
          await _saveToken(token);
          
          // Also save user info
          if (responseData.containsKey('user')) {
            final userInfo = responseData['user'];
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_info', jsonEncode(userInfo));
            print('👤 User info saved: ${userInfo['userName']}');
          }
          
          // Decode token for debugging
          final payload = decodeTokenPayload(token);
          if (payload != null) {
            print('🔓 Token payload:');
            print('  Subject: ${payload['sub']}');
            print('  Issued: ${DateTime.fromMillisecondsSinceEpoch(payload['iat'] * 1000)}');
            print('  Expires: ${DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)}');
            
            // Check if token is expired
            final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
            if (expiry.isBefore(DateTime.now())) {
              print('⚠️ WARNING: Token is already expired!');
            }
          }
          
          return {
            'success': true,
            'data': responseData,
            'token': token,
            'user': responseData['user'],
          };
        } else {
          print('❌ jwtToken not found in response!');
          print('Available keys: ${responseData.keys}');
          return {
            'success': false,
            'message': 'jwtToken not found in response',
            'response': responseData,
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid username or password',
          'status': 401,
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Login failed (${response.statusCode})',
            'status': response.statusCode,
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Login failed (${response.statusCode})',
            'status': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('❌ Network Exception: $e');
      return {
        'success': false, 
        'message': 'Connection failed. Check internet or server status.'
      };
    }
  }

  // SIGN UP METHOD - Updated
  static Future<Map<String, dynamic>> signUp({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final url = Uri.parse('$_baseUrl/api/auth/signup');
    
    final body = jsonEncode({
      'username': username,
      'password': password,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'roles': ['ROLE_USER'],
    });

    print('🚀 SIGN UP REQUEST');
    print('URL: $url');
    print('Body: $body');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'accept': '*/*',
        },
        body: body,
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData;
        try {
          responseData = jsonDecode(response.body);
          print('✅ Signup successful! Response: $responseData');
        } catch (e) {
          return {'success': false, 'message': 'Invalid response format'};
        }

        // Check if signup returns token immediately (some APIs do)
        String? token;
        if (responseData.containsKey('jwtToken')) {
          token = responseData['jwtToken'].toString();
          print('🔑 Found jwtToken in signup response');
        } else if (responseData.containsKey('token')) {
          token = responseData['token'].toString();
          print('🔑 Found token in signup response');
        }

        if (token != null) {
          await _saveToken(token);
          return {
            'success': true, 
            'data': responseData, 
            'token': token,
            'message': 'Account created and logged in successfully!'
          };
        } else {
          // Most signup APIs don't return token, need to login separately
          return {
            'success': true, 
            'data': responseData,
            'message': 'Account created successfully! Please sign in.'
          };
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = errorData['message'] ?? 'Signup failed';
          
          // Handle validation errors
          if (errorData.containsKey('errors')) {
            final errors = errorData['errors'];
            if (errors is List && errors.isNotEmpty) {
              errorMessage = errors.join(', ');
            }
          }
          
          return {'success': false, 'message': errorMessage};
        } catch (e) {
          return {
            'success': false, 
            'message': 'Signup failed (${response.statusCode})'
          };
        }
      }
    } catch (e) {
      print('❌ Signup Error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Decode JWT token
  static Map<String, dynamic>? decodeTokenPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT format: Expected 3 parts, got ${parts.length}');
        return null;
      }
      
      String payload = parts[1];
      // Fix base64 padding
      switch (payload.length % 4) {
        case 1: payload += '==='; break;
        case 2: payload += '=='; break;
        case 3: payload += '='; break;
      }
      
      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded);
    } catch (e) {
      print('❌ Token decode error: $e');
      return null;
    }
  }

  // Get user info from stored data
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('user_info');
    if (userInfoString != null) {
      try {
        return jsonDecode(userInfoString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Get current user name
  static Future<String?> getCurrentUserName() async {
    final userInfo = await getUserInfo();
    if (userInfo != null) {
      return userInfo['userName'] ?? userInfo['username'];
    }
    return null;
  }

  // Check authentication status
  static bool get isAuthenticated {
    if (_token == null) return false;
    
    // Check token expiration
    final payload = decodeTokenPayload(_token!);
    if (payload != null && payload.containsKey('exp')) {
      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      final now = DateTime.now();
      if (expiry.isBefore(now)) {
        print('⚠️ Token expired on $expiry');
        clearToken();
        return false;
      }
      print('✅ Token valid until $expiry');
    }
    
    return true;
  }

  // Test protected API endpoint
  static Future<Map<String, dynamic>> testProtectedApi() async {
    if (_token == null) {
      return {'success': false, 'message': 'No token available'};
    }
    
    final url = Uri.parse('$_baseUrl/api/users');
    
    try {
      print('🧪 Testing protected API with token...');
      final response = await http.get(
        url,
        headers: getHeaders(),
      );
      
      print('API Test Status: ${response.statusCode}');
      print('API Test Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          return {'success': true, 'data': data};
        } catch (e) {
          return {'success': true, 'data': response.body};
        }
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        return {
          'success': false, 
          'message': 'Access denied. Token may be invalid or expired.'
        };
      } else {
        return {
          'success': false, 
          'message': 'API request failed (${response.statusCode})'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'API test error: $e'};
    }
  }
}