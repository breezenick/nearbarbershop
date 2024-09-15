import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PhotoTab extends StatelessWidget {
  final String homePage;  // The Instagram URL

  PhotoTab({required this.homePage});

  Future<List<String>> fetchInstagramPhotos() async {
    final response = await http.get(
        Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/scrape?url=$homePage')
    );

    if (response.statusCode == 200) {
      List<String> photos = List<String>.from(json.decode(response.body));
      print(photos);  // Print the scraped photo URLs
      return photos;
    } else {
      throw Exception('Failed to load Instagram photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchInstagramPhotos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No photos available'));
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String imageUrl = snapshot.data![index];
              if (imageUrl != null && imageUrl.startsWith('http')) {
                return Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/barbershop02.jpg');  // Show a placeholder on error
                });
              } else {
                return Image.asset('assets/barbershop03.jpg');  // Show a placeholder for invalid URLs
              }
            },
          );
        }
      },
    );
  }
}
