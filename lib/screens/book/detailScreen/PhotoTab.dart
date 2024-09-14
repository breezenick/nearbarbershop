import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotoTab extends StatefulWidget {
  final String barbershopId;

  PhotoTab({required this.barbershopId});

  @override
  _PhotoTabState createState() => _PhotoTabState();
}

class _PhotoTabState extends State<PhotoTab> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchInstagramPhotos();
  }

  Future<void> _fetchInstagramPhotos() async {
    try {
      final response = await http.get(
          Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/photos')
      );

      if (response.statusCode == 200) {
        setState(() {
          imageUrls = List<String>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load photos');
      }
    } catch (e) {
      print('Error fetching photos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(imageUrls[index]),
        );
      },
    );
  }
}
