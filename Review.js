// Review.js
const express = require('express');
const Barbershop = require('./Barbershop');

const router = express.Router();

// Route to add a review
router.post('/:id/add-review', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { rating, comment, user } = req.body;

  if (!rating || !comment || !user || rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'Invalid input data. Make sure rating is between 1 and 5.' });
  }

  try {
    const result = await Barbershop.updateOne(
      { id: id },
      {
        $push: {
          reviews: {
            rating: rating,
            comment: comment,
            user: user,
            date: new Date(),
          },
        },
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: 'Barbershop not found' });
    }

    res.status(201).json({ message: 'Review added successfully' });
  } catch (error) {
    console.error('Failed to add review:', error);
    res.status(500).json({ message: 'Failed to add review' });
  }
});

// Route to fetch reviews
router.get('/:id/reviews', async (req, res) => {
  const id = req.params.id;
  try
