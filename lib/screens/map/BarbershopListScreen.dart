import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/barbershop.dart';
import '../../services/api_service.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

import '../book/detailScreen/BarbershopDetailScreen.dart';

class BarbershopListScreen extends StatefulWidget {
  const BarbershopListScreen({Key? key, required id}) : super(key: key);

  @override
  _BarbershopListScreenState createState() => _BarbershopListScreenState();
}

class _BarbershopListScreenState extends State<BarbershopListScreen> {
  final ApiService _apiService = ApiService();
  List<Barbershop> _barbershops = [];
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Get current location of the user
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      await _loadNearbyBarbershops(position.latitude, position.longitude);
    } catch (e) {
      developer.log('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load nearby barbershops based on current location
  Future<void> _loadNearbyBarbershops(double latitude, double longitude) async {
    try {
      List<Barbershop> barbershops = await _apiService.getBarbershops(latitude, longitude);

      // Sort barbershops by proximity to the current location
      barbershops.sort((a, b) => _calculateDistance(latitude, longitude, a.y!, a.x!)
          .compareTo(_calculateDistance(latitude, longitude, b.y!, b.x!)));

      setState(() {
        _barbershops = barbershops;
        _isLoading = false;
      });
    } catch (e) {
      developer.log('Error loading barbershops: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371e3; // Earth's radius in meters
    double phi1 = lat1 * (math.pi / 180);
    double phi2 = lat2 * (math.pi / 180);
    double deltaPhi = (lat2 - lat1) * (math.pi / 180);
    double deltaLambda = (lon2 - lon1) * (math.pi / 180);

    double a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // Distance in meters
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("근처 바버샵들"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _barbershops.isEmpty
          ? const Center(child: Text('No nearby barbershops found.'))
          : ListView.builder(
        itemCount: _barbershops.length,
        itemBuilder: (context, index) {
          Barbershop shop = _barbershops[index];
          double distance = _calculateDistance(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            shop.y!,
            shop.x!,
          );

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shop.thumUrl == null || shop.thumUrl?.isEmpty == true
                        ? Image.asset(
                      'assets/barbershop02.jpg',  // Default image if thumUrl is null or empty
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                    )
                        : Image.network(
                      shop.thumUrl?? '' ,  // Use the thumUrl if it's valid
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/barbershop02.jpg',  // Default image if thumUrl is invalid
                          width: double.infinity,
                          height: 240,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      shop.name ?? 'Unnamed Shop',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      shop.bizhourInfo ?? 'No business hours available',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      shop.address ?? 'Unknown Address',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10.0),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ElevatedButton(
                          child: const Text(
                            '예약하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BarbershopDetailScreen(
                                  barbershop: shop,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
