// File: lib/features/test/screens/connection_test_screen.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/api/api_service.dart';
import 'package:moovapp/core/service/auth_service.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({Key? key}) : super(key: key);

  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _testResult = 'En attente...';
  bool _isTesting = false;

  Future<void> _testBackendConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Test en cours...';
    });

    try {
      final apiService = ApiService();
      final result = await apiService.get('health');
      
      setState(() {
        _testResult = '✅ SUCCÈS: ${result['message']}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERREUR: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testUniversities() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Test universités...';
    });

    try {
      final apiService = ApiService();
      final result = await apiService.get('universities');
      
      setState(() {
        _testResult = '✅ UNIVERSITÉS: ${result['universities'].length} trouvées';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERREUR UNIVERSITÉS: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testAuth() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Test authentification...';
    });

    try {
      final authService = AuthService();
      final user = await authService.signIn('test@example.com', 'password');
      
      setState(() {
        _testResult = '✅ AUTH: Connecté en tant que ${user?.fullName}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERREUR AUTH: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Connexion Backend'),
        backgroundColor: Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Statut Backend',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _testResult,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _testResult.contains('✅') ? Colors.green : 
                               _testResult.contains('❌') ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTesting ? null : _testBackendConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isTesting 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Tester Connexion Backend'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isTesting ? null : _testUniversities,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text('Tester Universités'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isTesting ? null : _testAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text('Tester Authentification'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('1. Backend doit être démarré sur localhost:3000'),
                      Text('2. Testez d\'abord la connexion générale'),
                      Text('3. Puis testez les universités'),
                      Text('4. Enfin testez l\'authentification'),
                      SizedBox(height: 20),
                      Text(
                        'URLs de test:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text('• Health: http://localhost:3000/api/health'),
                      Text('• Universities: http://localhost:3000/api/universities'),
                      Text('• Auth: http://localhost:3000/api/auth/login'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}