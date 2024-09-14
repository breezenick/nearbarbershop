import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class PhotoTab extends StatelessWidget {
  final String homePage; // Now this is homePage instead of instagramUrl

  PhotoTab({required this.homePage});

  Future<List<String>> fetchInstagramPhotos() async {
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
              crossAxisCount: 2,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return Image.network(snapshot.data![index]);
            },
          );
        }
      },
    );
  }
}
