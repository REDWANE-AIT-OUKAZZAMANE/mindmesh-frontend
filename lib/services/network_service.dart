import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

class NetworkService {
  final ApiService _apiService;
  
  NetworkService(this._apiService);
  
  Future<bool> hasInternetConnection() async {
    try {
      // First check device connectivity
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      
      // Then try to reach common internet hosts
      bool reachable = await _canReachInternet();
      if (!reachable) {
        return false;
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking internet connection: $e');
      }
      return false;
    }
  }
  
  Future<bool> _canReachInternet() async {
    try {
      // Try multiple reliable hosts
      List<String> hosts = [
        'google.com',
        'cloudflare.com',
        'apple.com',
      ];
      
      for (String host in hosts) {
        try {
          final result = await InternetAddress.lookup(host);
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (_) {
          // Continue to next host
          continue;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> diagnoseConnectionIssue() async {
    final results = <String, dynamic>{};
    
    // 1. Check device connectivity
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      results['device_connectivity'] = connectivityResult.toString();
      results['has_connection'] = connectivityResult != ConnectivityResult.none;
    } catch (e) {
      results['device_connectivity_error'] = e.toString();
    }
    
    // 2. Check general internet
    try {
      final hasInternet = await _canReachInternet();
      results['internet_reachable'] = hasInternet;
    } catch (e) {
      results['internet_check_error'] = e.toString();
    }
    
    // 3. Try to reach backend specifically
    try {
      // Use a simple HEAD request with minimal data transfer
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      
      final response = await dio.head('https://mindmesh-backend-yp1t.onrender.com/api/health');
      results['backend_reachable'] = response.statusCode == 200;
      results['backend_status_code'] = response.statusCode;
    } catch (e) {
      if (e is DioException) {
        results['backend_error_type'] = e.type.toString();
        results['backend_error'] = e.message;
      } else {
        results['backend_error'] = e.toString();
      }
    }
    
    // 4. Try the API service's checker
    try {
      final apiConnectivity = await _apiService.checkConnectivity();
      results['api_service_connectivity'] = apiConnectivity;
    } catch (e) {
      results['api_service_error'] = e.toString();
    }
    
    if (kDebugMode) {
      print('Network diagnosis results:');
      results.forEach((key, value) {
        print('$key: $value');
      });
    }
    
    return results;
  }
}

final networkServiceProvider = Provider<NetworkService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NetworkService(apiService);
}); 