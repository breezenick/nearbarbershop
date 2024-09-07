import 'package:flutter/Material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../utils/DistanceNotifier.dart';
import '../../utils/places_notifier2.dart';
import '../../utils/providers_home.dart';
import '../Map/map_screen.dart';

class HomeBox extends ConsumerWidget {
  const HomeBox({super.key});

  //@override
  //_HomeBoxState createState() => _HomeBoxState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final selectedKm = ref.watch(distanceProvider);
    final selectedKm = ref.watch(kilometerProvider);
    print('selectedKm:=====================>>> $selectedKm');
    ref.watch(placesNotifierProvider2(selectedKm));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Nearby button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                 // primary: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.near_me, size: 24),
                    SizedBox(width: 8),
                    Text('NEARBY'),
                  ],
                ),
              ),
              SizedBox(width: 25),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                child:DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        value: selectedKm,
                        // newValue ==> value로 변경함. 20240126
                        // home_box.dart에서 하단의 소스들은 문제가 없는거 같음...
                        onChanged: (value) async {
                          print('Selected km:=====================>>> $value');
                          if (value != null) {
                            ref.read(kilometerProvider.notifier).state = value;
                            //ref.read(distanceProvider.notifier).updateDistance(value);

                            Position position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );

                            print('Selected km:=====================>>> $value');

                            ref.read(placesNotifierProvider2(selectedKm).notifier).fetchPlaces_test(value, position.latitude, position.longitude);
                            // Correct listening to kilometer changes and fetching places accordingly
                            /*ref.listen<double>(kilometerProvider, (previous, next) {
                              if (previous != next) {  // Only fetch new data if the kilometer value changes
                                ref.read(placesNotifierProvider2(selectedKm).notifier).fetchPlaces( );
                              }
                            });*/

                          }
                        },
                        items: [1.0, 3.0, 5.0, 10.0].map<DropdownMenuItem<double>>((double value) {
                          return DropdownMenuItem<double>(
                            value: value,
                            child: Text('$value km'),
                          );
                        }).toList(),
                      ))
              ),

            ],
          ),
        ],
      ),
    );
  }


}

