import 'dart:math';
import 'dart:ui';
import 'package:flutter/Material.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import '../../models/barbershop.dart';
import '../../utils/places_notifier2.dart';
import '../../utils/providers_home.dart';
import '../book/detailScreen/BarbershopDetailScreen.dart';

class LocationTest extends ConsumerWidget {
  const LocationTest({flutter.Key? key}) : super(key: key);

  @override
  flutter.Widget build(BuildContext context, WidgetRef ref) {
      final selectedKm = ref.watch(kilometerProvider);
      final shops = ref.watch(placesNotifierProvider2(selectedKm));

      return SizedBox(
        height: 440,
        child: shops.when(
          data: (List<Barbershop> shops) => PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Card(
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
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      );
    }
  }
