import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nearbarbershop2/models/barbershop.dart';
import 'package:nearbarbershop2/services/api_service.dart';

class PlacesNotifier2 extends StateNotifier<AsyncValue<List<Barbershop>>> {
  final double distance;

  PlacesNotifier2(this.distance) : super(AsyncValue.loading()) {
    fetchPlaces_test( distance, 0.0, 0.0); // Fetch places with initial radius
  }

  Future<void> fetchPlaces_test(double distance, double latitude,
      double longitude) async {
    double minDistance = 0.0;
    double maxDistance = 0.0;

    // Define distance ranges based on selection
    if (distance == 1.0) {
      minDistance = 0.0;
      maxDistance = 1.0;
    } else if (distance == 3.0) {
      minDistance = 1.5;
      maxDistance = 3.0;
    } else if (distance == 5.0) {
      minDistance = 4.0;
      maxDistance = 5.0;
    } else if (distance == 10.0) {
      minDistance = 10.0;
      maxDistance = 20.0;
    }
    ApiService apiService = ApiService();
    final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Fetch barbershops with min and max distance
    final places = await apiService.fetchBarbershops(
        minDistance, maxDistance, currentPosition.latitude,
        currentPosition.longitude);

    // Update the state with the new data
    state = AsyncValue.data(places);
  }
}
// If You Want to Use PlacesNotifier2 and fetchPlaces:
/*
final placesNotifierProvider2 = StateNotifierProvider<PlacesNotifier2, List<Barbershop>>((ref) {
  return PlacesNotifier2();
});
*/

final placesNotifierProvider2 = StateNotifierProvider.family<PlacesNotifier2, AsyncValue<List<Barbershop>>, double>((ref, selectedKm) {
  return PlacesNotifier2(selectedKm);  // Assumes constructor accepts and reacts to selectedKm
});

