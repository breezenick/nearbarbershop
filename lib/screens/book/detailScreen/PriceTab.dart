
import 'package:flutter/Material.dart';

class PriceTab extends StatelessWidget {
  final String? menuInfo;

  PriceTab({this.menuInfo});

  @override
  Widget build(BuildContext context) {
    // Parse the menuInfo into a list of price items
    List<Map<String, String>> priceData = _parseMenuInfo(menuInfo ?? '');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: priceData.length,
        itemBuilder: (context, index) {
          final item = priceData[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  item["title"] ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  item["price"] ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
    // Helper method to parse the menuInfo into a list of title-price pairs
    List<Map<String, String>> _parseMenuInfo(String menuInfo) {
      List<Map<String, String>> priceData = [];

      // Split by '|' to get individual services
      List<String> items = menuInfo.split('|');
      for (var item in items) {
        // Split each service into title and price using a space or other delimiter
        List<String> parts = item.trim().split(' ');
        if (parts.length >= 2) {
          // Join all parts except the last as title, and last part as price
          String title = parts.sublist(0, parts.length - 1).join(' ');
          String price = parts.last;
          priceData.add({"title": title, "price": price});
        }
      }

      return priceData;
    }
  }
