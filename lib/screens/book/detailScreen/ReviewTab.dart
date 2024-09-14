import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewTab extends StatefulWidget {
  final String barbershopId; // Pass the ID of the barbershop
  final String contextList;
  final List<String>? microReviewList;

  ReviewTab({required this.barbershopId, required this.contextList, required this.microReviewList});

  @override
  _ReviewTabState createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final TextEditingController _reviewController = TextEditingController();
  List<String> microReviewList = [];

  @override
  void initState() {
    super.initState();
    _fetchBarbershopData();
  }

  Future<void> _fetchBarbershopData() async {
    try {
      final data = await fetchBarbershop(widget.barbershopId);
      setState(() {
        microReviewList = List<String>.from(data['microReview'] ?? []);
      });
    } catch (error) {
      print('Failed to load barbershop data: $error');
    }
  }

  Future<void> _submitReview() async {
    final newReview = _reviewController.text;

    try {
      await submitReview(widget.barbershopId, newReview);
      setState(() {
        microReviewList.add(newReview);
        _reviewController.clear();
      });
    } catch (error) {
      print('Failed to submit review: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Review Input Form
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _reviewController,
            decoration: InputDecoration(
              labelText: 'Write your review',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _submitReview,
          child: Text('Submit Review'),
        ),

        // Review List
        Expanded(
          child: ListView.builder(
            itemCount: microReviewList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(microReviewList[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Fetch barbershop data
Future<Map<String, dynamic>> fetchBarbershop(String barbershopId) async {
  final response = await http.get(Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/$barbershopId'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load barbershop');
  }
}

// Submit a review
Future<void> submitReview(String barbershopId, String review) async {
  final response = await http.post(
    Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/$barbershopId/review'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({'microReview': review}),
  );

  if (response.statusCode == 200) {
    print('Review submitted successfully');
  } else {
    throw Exception('Failed to submit review');
  }
}
