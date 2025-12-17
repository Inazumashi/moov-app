// lib/screens/stats/eco_stats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/eco_stats_provider.dart';
import 'package:moovapp/core/service/eco_calculator_service.dart';


class EcoStatsScreen extends StatefulWidget {
  const EcoStatsScreen({super.key});

  @override
  State<EcoStatsScreen> createState() => _EcoStatsScreenState();
}

class _EcoStatsScreenState extends State<EcoStatsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialiser les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EcoStatsProvider>(context, listen: false)
          .loadCompletedTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EcoStatsProvider(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text('Statistiques Écologiques'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _showDateRangePicker(context),
              tooltip: 'Choisir une période',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<EcoStatsProvider>(context, listen: false)
                    .loadCompletedTrips();
              },
              tooltip: 'Actualiser',
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<EcoStatsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.completedTrips.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                provider.error,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadCompletedTrips();
          },
          child: ListView(
            children: [
              // Section 1: Header avec stats principales
              _buildHeaderStats(context, provider),
              
              // Section 2: Graphique mensuel
              _buildMonthlyChart(context, provider),
              
              // Section 3: Équivalences concrètes
              _buildEquivalences(context, provider),
              
              // Section 4: Détails des trajets
              _buildTripDetails(context, provider),
              
              // Section 5: Conseils écologiques
              _buildEcoTips(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderStats(BuildContext context, EcoStatsProvider provider) {
    final stats = provider.ecoStats;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Votre Impact Écologique',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // CO2 Économisé
          _buildStatCard(
            icon: Icons.eco,
            color: Colors.greenAccent,
            title: 'CO₂ Évité',
            value: EcoCalculatorService.formatCO2Saved(stats['co2_saved_kg'] ?? 0),
            subtitle: 'Émissions économisées',
          ),
          
          const SizedBox(height: 16),
          
          // Argent Économisé
          _buildStatCard(
            icon: Icons.monetization_on,
            color: Colors.amber,
            title: 'Économies',
            value: EcoCalculatorService.formatMoneySaved(stats['money_saved_dh'] ?? 0),
            subtitle: 'DH économisés',
          ),
          
          const SizedBox(height: 16),
          
          // Distance parcourue
          Row(
            children: [
              Expanded(
                child: _buildSmallStatCard(
                  icon: Icons.directions_car,
                  color: Colors.blue.shade300,
                  title: 'Distance',
                  value: '${stats['total_distance']?.round() ?? 0} km',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallStatCard(
                  icon: Icons.people,
                  color: Colors.purple.shade300,
                  title: 'Passagers',
                  value: '${stats['total_passengers']?.round() ?? 0}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSmallStatCard(
                  icon: Icons.park,
                  color: Colors.green.shade300,
                  title: 'Arbres',
                  value: '${provider.treesEquivalent.round()}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, EcoStatsProvider provider) {
    if (provider.monthlyEcoData.isEmpty) {
      return Container();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Évolution Mensuelle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: provider.monthlyEcoData.length,
                itemBuilder: (context, index) {
                  final data = provider.monthlyEcoData[index];
                  final maxCo2 = provider.monthlyEcoData
                      .map((e) => e['co2_saved'] as double)
                      .reduce((a, b) => a > b ? a : b);
                  
                  final height = (data['co2_saved'] as double) / maxCo2 * 150;
                  
                  return Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          data['month'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade400, Colors.green.shade700],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${data['co2_saved'].round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${data['trips_count']} trajets',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquivalences(BuildContext context, EcoStatsProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre Impact en Équivalences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildEquivalenceCard(
                  icon: Icons.park,
                  title: 'Arbres plantés',
                  value: '${provider.treesEquivalent.round()}',
                  subtitle: 'équivalent',
                  color: Colors.green,
                ),
                const SizedBox(width: 10),
                _buildEquivalenceCard(
                  icon: Icons.local_drink,
                  title: 'Bouteilles plastique',
                  value: '${provider.plasticBottlesEquivalent}',
                  subtitle: 'non produites',
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildEquivalenceCard(
                  icon: Icons.smartphone,
                  title: 'Charges smartphone',
                  value: '${provider.smartphoneChargesEquivalent}',
                  subtitle: 'équivalent',
                  color: Colors.purple,
                ),
                const SizedBox(width: 10),
                _buildEquivalenceCard(
                  icon: Icons.lightbulb,
                  title: 'Ampoules LED',
                  value: '${((provider.ecoStats['co2_saved_kg'] ?? 0) * 1000 / 8).round()}',
                  subtitle: 'pendant 1 heure',
                  color: Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetails(BuildContext context, EcoStatsProvider provider) {
    if (provider.completedTrips.isEmpty) {
      return Container();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Détails des Trajets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...provider.completedTrips.map((trip) {
              return _buildTripTile(trip);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoTips(BuildContext context) {
    final tips = [
      {
        'icon': Icons.group,
        'title': 'Optimisez le covoiturage',
        'description': 'Remplissez votre voiture pour maximiser les économies',
      },
      {
        'icon': Icons.directions_car,
        'title': 'Entretenez votre véhicule',
        'description': 'Un véhicule bien entretenu consomme moins',
      },
      {
        'icon': Icons.speed,
        'title': 'Conduite éco-responsable',
        'description': 'Évitez les accélérations brusques',
      },
      {
        'icon': Icons.eco,
        'title': 'Compensez votre empreinte',
        'description': 'Plantez un arbre pour vos trajets restants',
      },
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conseils pour Augmenter Votre Impact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...tips.map((tip) {
              return ListTile(
                leading: Icon(tip['icon'] as IconData, color: Colors.green),
                title: Text(tip['title'] as String),
                subtitle: Text(tip['description'] as String),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquivalenceCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripTile(Map<String, dynamic> trip) {
    final distance = trip['distance']?.toDouble() ?? 0.0;
    final passengers = trip['passengers'] as int? ?? 0;
    final isDriver = trip['is_driver'] == true;
    
    final co2Saved = EcoCalculatorService.calculateCO2Saved(
      totalDistance: distance,
      numberOfPeople: passengers + (isDriver ? 1 : 0),
      fuelType: trip['vehicle_type'] == 'diesel' 
          ? FuelType.diesel 
          : FuelType.gasoline,
    );
    
    final moneySaved = isDriver
        ? EcoCalculatorService.calculateMoneySaved(
            totalDistance: distance,
            pricePerPerson: trip['price_per_seat']?.toDouble() ?? 0,
            numberOfPassengers: passengers,
          )
        : EcoCalculatorService.calculatePassengerSavings(
            totalDistance: distance,
            pricePerPerson: trip['price_per_seat']?.toDouble() ?? 0,
          );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          isDriver ? Icons.drive_eta : Icons.person,
          color: isDriver ? Colors.blue : Colors.green,
        ),
        title: Text('${trip['from']} → ${trip['to']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${distance.round()} km • ${passengers} passagers'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(
                    '${co2Saved.round()} kg CO₂',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.green.shade100,
                ),
                const SizedBox(width: 4),
                Chip(
                  label: Text(
                    '${moneySaved.round()} DH',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.amber.shade100,
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          trip['date'].toString().substring(0, 10),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final provider = Provider.of<EcoStatsProvider>(context, listen: false);
    
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023, 1, 1),
      lastDate: DateTime.now(),
      initialDateRange: provider.selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green,
            colorScheme: const ColorScheme.light(primary: Colors.green),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      await provider.setDateRange(picked);
    }
  }
}