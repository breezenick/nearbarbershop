import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewTab extends StatefulWidget {
  final int? barbershopId;

  ReviewTab({required this.barbershopId});

  @override
  _ReviewTabState createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {
  final _reviewController = TextEditingController();
  final _ratingController = TextEditingController();

  // Function to fetch reviews from the backend (GET request)
  Future<List<dynamic>> fetchReviews() async {
    final response = await http.get(
      Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/reviews'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  // Function to submit a review to the backend (POST request)
  Future<void> submitReview() async {
    final response = await http.post(
      Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/${widget.barbershopId}/add-review'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "rating": int.parse(_ratingController.text),
        "comment": _reviewController.text,
        "user": "User123",  // Adjust as necessary to include user context
      }),
    );

    if (response.statusCode == 200) {
      _reviewController.clear();
      _ratingController.clear();
      setState(() {}); // Refresh the review list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${response.body}'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text("Failed to load reviews"));
          } else if (snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No reviews yet.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _showSubmitReviewDialog(),
                    child: Text('Add Review'),
                  ),
                ],
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var review = snapshot.data![index];
                      return ListTile(
                        title: Text(review['comment']),
                        subtitle: Text('Rating: ${review['rating']} - ${review['user']}'),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showSubmitReviewDialog(),
                  child: Text('Add Review'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _showSubmitReviewDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Submit Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating (1-5)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(labelText: 'Review'),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                submitReview();
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without submitting
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
