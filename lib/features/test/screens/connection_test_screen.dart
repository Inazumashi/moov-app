// File: lib/features/test/screens/connection_test_screen.dart
import 'package:flutter/material.dart';
import 'package:moovapp/core/api/api_service.dart';

class ConnectionTestScreen extends StatefulWidget {
  const ConnectionTestScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _testResult = 'En attente...';
  bool _isTesting = false;

  Future<void> _testHealth() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Test santé API...';
    });

    try {
      final apiService = ApiService();
      final result = await apiService.get('health', isProtected: false);

      setState(() {
        _testResult = '✅ SANTÉ API: ${result['status']} - ${result['service']}';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ ERREUR SANTÉ: $e';
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
      _testResult = 'Test liste universités...';
    });

    try {
      final apiService = ApiService();
      // CORRECTION: Utilisez la bonne route '/api/auth/universities'
      final result = await apiService.get('auth/universities', isProtected: false);

      if (result['success'] == true) {
        final universities = result['universities'] ?? [];
        setState(() {
          _testResult = '✅ UNIVERSITÉS: ${universities.length} trouvées\n\n';
          for (var i = 0; i < universities.length && i < 3; i++) {
            _testResult += '• ${universities[i]['name']}\n';
          }
          if (universities.length > 3) {
            _testResult += '... et ${universities.length - 3} autres';
          }
        });
      } else {
        setState(() {
          _testResult = '❌ UNIVERSITÉS: ${result['message']}';
        });
      }
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

  Future<void> _testStations() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Test stations populaires...';
    });

    try {
      final apiService = ApiService();
      // Testez les stations populaires (pas besoin de paramètres)
      final result = await apiService.get('stations/popular', isProtected: false);

      if (result['success'] == true) {
        final stations = result['stations'] ?? [];
        setState(() {
          _testResult = '✅ STATIONS: ${stations.length} trouvées\n';
          if (stations.isNotEmpty) {
            _testResult += 'Exemple: ${stations[0]['name']}';
          }
        });
      } else {
        setState(() {
          _testResult = '❌ STATIONS: ${result['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _testResult = '❌ ERREUR STATIONS: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = 'Test connexion complète...';
    });

    try {
      final apiService = ApiService();
      
      // Test 1: Health
      final health = await apiService.get('health', isProtected: false);
      
      // Test 2: Universities
      final universities = await apiService.get('auth/universities', isProtected: false);
      
      // Test 3: Stations
      final stations = await apiService.get('stations/popular?limit=3', isProtected: false);
      
      setState(() {
        _testResult = '''
✅ TEST COMPLET RÉUSSI!

1. Santé API: ${health['status']}
2. Universités: ${universities['universities']?.length ?? 0} disponibles
3. Stations: ${stations['stations']?.length ?? 0} populaires

Backend opérationnel! 🚀
        ''';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ TEST COMPLET ÉCHOUÉ: $e';
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
        title: const Text('Test Connexion Backend'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Statut Backend',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _testResult,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _testResult.contains('✅')
                            ? Colors.green
                            : _testResult.contains('❌')
                                ? Colors.red
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Bouton Test Complet
            ElevatedButton(
              onPressed: _isTesting ? null : _testConnection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isTesting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test Complet'),
            ),
            
            const SizedBox(height: 10),
            
            // Boutons de test individuels
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testHealth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Santé'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testUniversities,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Universités'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testStations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Stations'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Informations
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations de connexion:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text('URL base: http://localhost:3000/api'),
                      Text('Port: 5000 (Android) / 3000 (serveur)'),
                      const SizedBox(height: 20),
                      const Text(
                        'Routes testées:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text('• /api/health → Santé API'),
                      const Text('• /api/auth/universities → Liste universités'),
                      const Text('• /api/stations/popular → Stations populaires'),
                      const SizedBox(height: 20),
                      const Text(
                        'Problèmes courants:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      const Text('1. Serveur non démarré'),
                      const Text('2. Mauvais port (5000 vs 3000)'),
                      const Text('3. CORS mal configuré'),
                      const Text('4. Route inexistante'),
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