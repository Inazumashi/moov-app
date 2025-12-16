import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:moovapp/core/providers/stats_provider.dart';
import 'package:moovapp/core/providers/auth_provider.dart';

class StatsDashboardScreen extends StatefulWidget {
  const StatsDashboardScreen({super.key});

  @override
  State<StatsDashboardScreen> createState() => _StatsDashboardScreenState();
}

class _StatsDashboardScreenState extends State<StatsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadStats() {
    Provider.of<StatsProvider>(context, listen: false).refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final userRole = authProvider.currentUser?.profileType ?? 'passenger';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: const Text('Mes Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.onPrimary,
          unselectedLabelColor: colors.onPrimary.withOpacity(0.6),
          indicatorColor: colors.onPrimary,
          tabs: const [
            Tab(text: 'Vue d\'ensemble'),
            Tab(text: 'Activité'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, colors, userRole),
            _buildActivityTab(context, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    ColorScheme colors,
    String userRole,
  ) {
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, _) {
        if (statsProvider.isLoading && statsProvider.dashboardStats == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = statsProvider.dashboardStats ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userRole == 'conductor'
                          ? 'Conducteur depuis ${stats['memberSince'] ?? 'N/A'}'
                          : 'Passager depuis ${stats['memberSince'] ?? 'N/A'}',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${stats['totalTrips'] ?? 0} trajets',
                      style: TextStyle(
                        color: colors.onPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildStatCard(
                title: 'Note moyenne',
                value: '${stats['averageRating']?.toStringAsFixed(1) ?? 'N/A'} / 5',
                icon: Icons.star,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: 'Trajets ce mois',
                value: '${stats['tripsThisMonth'] ?? 0}',
                icon: Icons.calendar_month,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: 'Km parcourus',
                value: '${stats['totalDistance'] ?? 0} km',
                icon: Icons.directions_car,
                colors: colors,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: 'CO₂ économisés',
                value: '${stats['co2Saved'] ?? 0} kg',
                icon: Icons.eco,
                colors: colors,
              ),
              if (userRole == 'conductor') ...[
                const SizedBox(height: 20),
                Text(
                  'Données de conducteur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Passagers satisfaits',
                  value: '${stats['satisfiedPassengers'] ?? 0}%',
                  icon: Icons.thumb_up,
                  colors: colors,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityTab(BuildContext context, ColorScheme colors) {
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, _) {
        if (statsProvider.isLoading && statsProvider.recentActivity.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final activities = statsProvider.recentActivity;

        if (activities.isEmpty) {
          return Center(
            child: Text(
              'Aucune activité récente',
              style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityItem(activity, colors);
          },
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required ColorScheme colors,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildActivityItem(
    Map<String, dynamic> activity,
    ColorScheme colors,
  ) {
    final type = activity['type'] ?? 'ride';
    final title = activity['title'] ?? 'Événement';
    final timestamp = activity['timestamp'] ?? '';

    IconData icon = Icons.directions_car;
    if (type == 'rating') {
      icon = Icons.star;
    } else if (type == 'review') {
      icon = Icons.comment;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(title),
        subtitle: Text(_formatActivityTime(timestamp)),
        trailing: Icon(Icons.arrow_forward, color: colors.outline),
      ),
    );
  }

  String _formatActivityTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return 'il y a ${difference.inMinutes} minutes';
        }
        return 'il y a ${difference.inHours}h';
      } else if (difference.inDays == 1) {
        return 'Hier';
      } else {
        return 'Il y a ${difference.inDays} jours';
      }
    } catch (e) {
      return 'Date inconnue';
    }
  }
}
