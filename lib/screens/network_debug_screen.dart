import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindmesh/services/api_service.dart';

class NetworkDebugScreen extends ConsumerStatefulWidget {
  const NetworkDebugScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NetworkDebugScreen> createState() => _NetworkDebugScreenState();
}

class _NetworkDebugScreenState extends ConsumerState<NetworkDebugScreen> {
  bool _isDiagnosing = false;
  String _diagnosisResult = '';
  final List<String> _logs = [];
  late final TextEditingController _apiUrlController;
  
  @override
  void initState() {
    super.initState();
    _apiUrlController = TextEditingController(
      text: 'https://mindmesh-backend-yp1t.onrender.com/api'
    );
  }
  
  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _runDiagnosis() async {
    if (_isDiagnosing) return;
    
    setState(() {
      _isDiagnosing = true;
      _logs.clear();
      _diagnosisResult = 'Running diagnosis...';
    });
    
    try {
      _addLog('Starting network diagnosis');
      
      // Test internet connection
      _addLog('Checking internet connection...');
      bool hasInternet = await _checkInternetConnection();
      _addLog('Internet connection: ${hasInternet ? "Available" : "Not available"}');
      
      // Try to resolve domain
      _addLog('Checking DNS resolution...');
      bool canResolveDomain = await _checkDnsResolution();
      _addLog('DNS resolution: ${canResolveDomain ? "Success" : "Failed"}');
      
      // Try to connect to API
      _addLog('Checking API connection...');
      final apiUrl = _apiUrlController.text.trim();
      _addLog('Testing API URL: $apiUrl');
      
      final apiResponse = await _testApiConnection(apiUrl);
      _addLog('API connection result: $apiResponse');
      
      // Final assessment
      String diagnosisResult = 'Network Diagnosis Results:\n';
      diagnosisResult += 'Internet: ${hasInternet ? "✓" : "✗"}\n';
      diagnosisResult += 'DNS: ${canResolveDomain ? "✓" : "✗"}\n';
      diagnosisResult += 'API Connection: ${apiResponse.contains("success") ? "✓" : "✗"}\n\n';
      
      if (!hasInternet) {
        diagnosisResult += "Problem: No internet connection.\n";
        diagnosisResult += "Solution: Check your device's internet connection, WiFi, or mobile data.\n";
      } else if (!canResolveDomain) {
        diagnosisResult += "Problem: Cannot resolve the backend domain.\n";
        diagnosisResult += "Solution: DNS issue or the server domain is incorrect.\n";
      } else if (!apiResponse.contains("success")) {
        diagnosisResult += "Problem: Cannot connect to the API server.\n";
        diagnosisResult += "Solution: The server might be down or the URL is incorrect.\n";
      } else {
        diagnosisResult += "Everything seems to be working correctly.\n";
        diagnosisResult += "If you're still having issues, please check your login credentials or the specific API endpoint you're trying to access.\n";
      }
      
      setState(() {
        _diagnosisResult = diagnosisResult;
      });
      
    } catch (e) {
      _addLog('Error during diagnosis: $e');
      setState(() {
        _diagnosisResult = 'Diagnosis failed with error: $e';
      });
    } finally {
      setState(() {
        _isDiagnosing = false;
      });
    }
  }
  
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _addLog('Internet check error: $e');
      return false;
    }
  }
  
  Future<bool> _checkDnsResolution() async {
    try {
      final url = Uri.parse(_apiUrlController.text.trim());
      final host = url.host;
      _addLog('Resolving host: $host');
      
      final result = await InternetAddress.lookup(host);
      _addLog('DNS results: ${result.map((r) => r.address).join(', ')}');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _addLog('DNS resolution error: $e');
      return false;
    }
  }
  
  Future<String> _testApiConnection(String apiUrl) async {
    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      // Try multiple URL formats
      final urls = [
        apiUrl.endsWith('/') ? '${apiUrl}health' : '$apiUrl/health',
        apiUrl.endsWith('/api/') ? '${apiUrl}health' : 
          apiUrl.endsWith('/api') ? '$apiUrl/health' :
          apiUrl.endsWith('/') ? '${apiUrl}api/health' : '$apiUrl/api/health',
        // Try without /api
        apiUrl.contains('/api') ? apiUrl.replaceAll('/api', '') + '/health' : '$apiUrl/health',
      ];
      
      for (final url in urls) {
        try {
          _addLog('Trying to connect to: $url');
          final response = await dio.get(url);
          
          _addLog('Response status: ${response.statusCode}');
          _addLog('Response data: ${response.data}');
          
          if (response.statusCode == 200) {
            _addLog('✅ Success with URL: $url');
            return "success: API is reachable at $url";
          }
        } catch (e) {
          _addLog('Failed with URL: $url');
          // Continue to next URL
        }
      }
      
      return "failed: All URL variations tried";
    } catch (e) {
      _addLog('API connection error: $e');
      if (e is DioException) {
        _addLog('Dio error type: ${e.type}');
        _addLog('Dio error message: ${e.message}');
        
        // Help diagnose different types of errors
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            return "failed: Connection timeout - Server too slow or unreachable";
          case DioExceptionType.connectionError:
            return "failed: Connection error - Server unreachable";
          case DioExceptionType.badResponse:
            return "failed: Bad response (${e.response?.statusCode}) - ${e.response?.statusMessage}";
          default:
            return "failed: ${e.type} - ${e.message}";
        }
      }
      return "failed: $e";
    }
  }
  
  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $log');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Check Network Connectivity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiUrlController,
                decoration: const InputDecoration(
                  labelText: 'API URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isDiagnosing ? null : _runDiagnosis,
                child: Text(_isDiagnosing ? 'Running...' : 'Run Diagnostics'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Diagnosis Result:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_diagnosisResult),
              ),
              const SizedBox(height: 24),
              const Text(
                'Diagnosis Logs:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logs.join('\n'),
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 