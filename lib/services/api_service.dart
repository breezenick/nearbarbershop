import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/barbershop.dart';
import 'dart:math' as math;

class ApiService {

  Future<List<Barbershop>> getBarbershops(double latitude, double longitude) async {
    final String baseUrl = 'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops';
    Uri url = Uri.parse('$baseUrl?lat=$latitude&lng=$longitude');
    developer.log('Fetching barbershop data: $url');

    try {
      var response = await http.get(url);
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var decodedJson = jsonDecode(response.body) as List;
        return decodedJson.map((item) => Barbershop.fromJson(item)).toList();
      } else {
        developer.log('Failed to load with status code: ${response.statusCode}');
        throw Exception('Failed to load barbershops with status code: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching barbershops: $e');
      throw Exception('Error fetching barbershops: $e');
    }
  }



   Future<List<Barbershop>> fetchBarbershops(double minDistance, double maxDistance, latitude, double longitude) async {
    final String baseUrl = 'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops';
    final Uri url = Uri.parse('$baseUrl?lat=$latitude&lng=$longitude&distance=$maxDistance');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Barbershop> shops = data.map((shop) => Barbershop.fromJson(shop)).toList();

      // Optionally filter shops based on distance if not done by the API
      final filteredShops = shops.where((shop) {
        final shopDistance = _calculateDistance(latitude, longitude, shop.y!, shop.x!);

        return shopDistance >= minDistance && shopDistance <= maxDistance; // Filter based on provided distance
      }).toList();

      // Log the distance for each shop after sorting
      for (var shop in shops) {
        developer.log('Distance to shop (${shop.name}): ${_calculateDistance(latitude, longitude, shop.y!, shop.x!)} km');
      }

/*      // Sort the filtered list
      filteredShops.sort((a, b) => _calculateDistance(latitude, longitude, a.y!, a.x!)
          .compareTo(_calculateDistance(latitude, longitude, b.y!, b.x!)));*/

      return filteredShops;
    } else {
      throw Exception('Failed to load barbershops');
    }
  }




  static double _calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    final double dLat = _degreesToRadians(endLatitude - startLatitude);
    final double dLon = _degreesToRadians(endLongitude - startLongitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(startLatitude)) * math.cos(_degreesToRadians(endLatitude)) *
            math.sin(dLon / 2) * math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c;

    return distance;
  }
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

}
