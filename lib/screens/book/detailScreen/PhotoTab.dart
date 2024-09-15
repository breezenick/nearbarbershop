import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

class PhotoTab extends StatelessWidget {
  final String homePage;

  PhotoTab({required this.homePage});

  Future<List<String>> fetchInstagramPhotos() async {
    final response = await http.get(
        Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/scrape?url=$homePage')
    );
    print('Request URL:============================== ${response.request!.url}');  // Check the request URL
    print('Response Status Code:===================== ${response.statusCode}');
    print('Response Body:============================  ${response.body}');  // Check the response body


    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('Parsed JSON:============================ $jsonResponse');  // Print the parsed JSON

      // Check if the response is a List of photos and return it
      if (jsonResponse is List) {
        List<String> photos = List<String>.from(jsonResponse);
        print('Photos:================================= $photos');  // Check the extracted photos
        return photos;
      } else {
        print('Unexpected response format');
        return [];
      }
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              String imageUrl = snapshot.data![index];
              if (imageUrl != null && imageUrl.startsWith('http')) {
                return CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),  // Show an error icon if the image fails to load
                  fit: BoxFit.cover,  // Adjust the image to cover the grid item
                );
              } else {
                return Image.asset('assets/google_logo.png');  // Show a placeholder for invalid URLs
              }
            },
          );
        }
      },
    );
  }
}
