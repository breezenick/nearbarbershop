import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotoTab extends StatelessWidget {
  final String homePage;

  PhotoTab({required this.homePage});

  Future<List<String>> fetchInstagramPhotos7() async {
    final response = await http.get(
        Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/scrape?url=$homePage')
    );
    if (response.statusCode == 200) {
      List<String> photos = List<String>.from(json.decode(response.body));
      print(photos);  // Check what URLs are actually fetched
      return photos;
    } else {
      throw Exception('Failed to load Instagram photos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchInstagramPhotos7(), // Call the function that fetches the photos
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Show error message if something goes wrong
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No photos available')); // Handle case where no photos are available
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Two photos per row
            ),
            itemCount: snapshot.data!.length, // The number of items in the fetched photos list
            itemBuilder: (context, index) {
              return
               // Image.network(snapshot.data![index], fit: BoxFit.cover); // Display each photo using Image.network
                Image.network(
                  homePage != null && homePage.startsWith('http') ? homePage : 'assets/barbershop.jpg',
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/barbershop03.jpg');  // Fallback image in assets
                  },
                  fit: BoxFit.cover,
                );
            },
          );
        }
      },
    );
  }
}
