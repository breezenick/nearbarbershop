import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotoTab extends StatefulWidget {
  final String homePage;

  PhotoTab({required this.homePage});

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  late Future<List<String>> _photos;

  @override
  void initState() {
    super.initState();
    _photos = fetchPhotos();
  }


  Future<Map<String, dynamic>> fetchBarbershopByHomePage(String homePageUrl) async {
    final response = await http.get(
        Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops?homePage=$homePageUrl')
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve barbershop');
    }
  }


  // Function to fetch image URLs from the backend
  Future<List<String>> fetchPhotos() async {
    // Properly encode the Instagram URL
    final encodedUrl = Uri.encodeComponent(widget.homePage);
    print('Encoded URL: $encodedUrl');

    // Make the API call with the encoded URL
    final response = await http.get(
        Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/scrape?url=$encodedUrl')
    );

    if (response.statusCode == 200) {
      List<dynamic> images = jsonDecode(response.body);
      print('Images:=========================>>> $images');

      return images.map((img) => img.toString()).toList();

    } else {
      throw Exception('Failed to retrieve barbershop');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instagram Photos'),
      ),
      body: FutureBuilder<List<String>>(
        future: _photos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No photos available'));
          }

          final photos = snapshot.data!;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // Number of images per row
              childAspectRatio: 1.0,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.network(
                  photos[index], // Load image from the URL
                  fit: BoxFit.cover,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
