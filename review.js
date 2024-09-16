const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

// Assuming you've already connected to MongoDB in a separate file like `database.js`

// Route to add a review to the cheonan_test collection
router.post('/cheonan/review', async (req, res) => {
  try {
    const { review, rating, user, barbershopId } = req.body;

    // Find the specific document by barbershopId and update it with a new review
    const result = await mongoose.connection.collection('cheonan_test').updateOne(
      { _id: mongoose.Types.ObjectId(barbershopId) },  // Find the document by ID
      {
        $push: {
          reviews: {
            comment: review,
            rating: rating,
            user: user,
            date: new Date()
          }
        }
      }
    );

    // Check if the update was successful
    if (result.modifiedCount > 0) {
      res.status(200).send('Review added successfully');
    } else {
      res.status(404).send('Barbershop not found');
    }

  } catch (err) {
    res.status(500).send('Error saving review: ' + err.message);
  }
});

module.exports = router;
