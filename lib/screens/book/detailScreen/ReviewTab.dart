import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
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
      Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/barbershops/cheonan/reviews'),
    );
    if (response.statusCode == 200) {
      List<dynamic> reviews = jsonDecode(response.body);
      return reviews;
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  // Function to submit a review to the backend (POST request)
  Future<void> submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    final googleUserId = user?.uid;

    if (widget.barbershopId != null) {
      try {
        final response = await http.post(
          Uri.parse('https://nearbarbershop-fd0337b6be1a.herokuapp.com/api/cheonan/review'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "review": _reviewController.text,
            "rating": _ratingController.text,
            "user": googleUserId ?? "Unknown User",
            "barbershopId": widget.barbershopId
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Review submitted successfully')),
          );
          _reviewController.clear();
          _ratingController.clear();
          setState(() {}); // Refresh reviews after submission
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit review')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barbershop ID is missing')),
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
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading reviews'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Show "No reviews" message and the "Submit Review" button if there are no reviews
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No reviews available. Be the first to submit!'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _showSubmitReviewDialog(context); // Show the submit review dialog
                    },
                    child: Text('Submit Review'),
                  ),
                ],
              ),
            );
          } else {
            // If there are reviews, display them in a list
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(reviews[index]['comment'] ?? 'No comment'),
                  subtitle: Text('Rating: ${reviews[index]['rating'] ?? 'N/A'}'),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Function to show a dialog for submitting a review
  void _showSubmitReviewDialog(BuildContext context) {
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
                submitReview(); // Call the submit review function
                Navigator.of(context).pop(); // Close the dialog
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
