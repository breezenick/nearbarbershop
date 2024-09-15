import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PhotoTab extends StatelessWidget {
  final List<String> homePage; // Now this is homePage instead of instagramUrl

  PhotoTab({required this.homePage});

  Future<List<String>> fetchInstagramPhotos(String homePage) async {
    final response = await http.get(Uri.parse(
        'https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/scrape?url=$homePage'));

    if (response.statusCode == 200) {
      List<dynamic> photos = json.decode(response.body);
      return photos.cast<String>(); // Convert to List<String>
    } else {
      throw Exception('Failed to load Instagram photos');
    }
  }

/*  Future<List<String>> fetchInstagramPhotos9999() async {
    if (!homePage.contains("instagram.com")) {
      throw Exception("Invalid Instagram URL");
    }

    final response = await http.get(Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/scrape?url=$homePage'));

    if (response.statusCode == 200) {
      List<dynamic> photos = json.decode(response.body);
      print('Photos:=====================>>>  $photos');
      return photos.cast<String>();
    } else {
      throw Exception('Failed to load photos');
    }
  }*/

  @override
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two photos per row
      ),
      itemCount: homePage.length,
      itemBuilder: (context, index) {
        return Image.network(homePage[index]);
      },
    );
  }
}
