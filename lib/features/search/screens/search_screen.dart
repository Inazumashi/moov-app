import 'package:flutter/material.dart';
import 'package:moovapp/features/search/widgets/ride_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _showAd = true;

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            expandedHeight: 360.0,   // 🔥 Corrigé : hauteur augmentée
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              
              background: SafeArea(
                child: SingleChildScrollView( // 🔥 Corrigé : empêche tout overflow
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
                    child: _buildSearchForm(primaryColor),
                  ),
                ),
              ),
            ),
          ),

          // --- RESULTS LIST ---
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_showAd) _buildAdCard(),

                      _buildResultsHeader(primaryColor),
                      const SizedBox(height: 12),

                      // RESULT CARD 1
                      const RideResultCard(
                        name: 'Karim El Idrissi',
                        rating: 4.7,
                        departure: 'Ben Guerir',
                        departureDetail: 'Départ',
                        arrival: 'Casablanca',
                        arrivalDetail: 'Arrivée',
                        dateTime: '12 Oct • 15:00',
                        price: '70 MAD',
                        seats: 4,
                        tag: 'UM6P - Étudiants',
                      ),
                      const SizedBox(height: 12),

                      // RESULT CARD 2
                      const RideResultCard(
                        name: 'Amina Laaroussi',
                        rating: 4.9,
                        departure: 'UM6P Campus',
                        departureDetail: 'Départ',
                        arrival: 'Marrakech',
                        arrivalDetail: 'Arrivée',
                        dateTime: '13 Oct • 09:00',
                        price: '45 MAD',
                        seats: 2,
                        isPremium: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // 🔷 FORMULAIRE DE RECHERCHE
  // ----------------------------
  Widget _buildSearchForm(Color primaryColor) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Départ',
            prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          decoration: InputDecoration(
            hintText: 'Arrivée',
            prefixIcon: Icon(Icons.location_on, color: Colors.green[600]),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'jj/mm/aaaa',
                  prefixIcon: Icon(Icons.calendar_today_outlined, color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                padding: const EdgeInsets.all(14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text('Rechercher'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // 🔶 CARTE PUBLICITÉ
  // ----------------------------
  Widget _buildAdCard() {
    return Card(
      elevation: 0,
      color: const Color(0xFFfff8e1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.yellow.shade700.withOpacity(0.5)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow.shade700,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'AD',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Passez à Premium pour une expérience sans pub',
                style: TextStyle(fontSize: 13),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.grey[700]),
              onPressed: () {
                setState(() {
                  _showAd = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // 🔵 HEADER DES RESULTATS
  // ----------------------------
  Widget _buildResultsHeader(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Résultats (2)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'Trier par prix',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
