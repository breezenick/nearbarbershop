const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection
const Barbershop = require('./Barbershop');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});


// Fetch all barbershops
app.get('/barbershops', async (req, res) => {
    try {
        //const Barbershop = mongoose.connection.collection('cheonan_test'); // Access the correct collection
        //const results = await Barbershop.find({}).toArray(); // Fetch all documents from the collection
        const results = await Barbershop.find({}); // Fetch all documents from the collection

        res.json(results);
    } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).send('Failed to retrieve data');
    }
});

// Add a photo to a barbershop
app.post('/barbershops/:id/add-photo', async (req, res) => {
  const id = parseInt(req.params.id, 10);

  const { url, description } = req.body;
  if (!url) {
    return res.status(400).json({ message: 'Photo URL is required.' });
  }

  try {
    const result = await Barbershop.updateOne(
      { id: id },
      {
        $push: {
          photos: {
            url: url,
            description: description || '',
            date: new Date()
          }
        }
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: 'Barbershop not found' });
    }

    res.status(201).json({ message: 'Photo added successfully' });
  } catch (error) {
    console.error('Failed to add photo:', error);
    res.status(500).json({ message: 'Failed to add photo' });
  }
});


// Fetch photos for a specific barbershop
app.get('/barbershops/:id/photos', async (req, res) => {
  const id = parseInt(req.params.id, 10);  // Ensure the ID is an integer

  try {
    const barbershop = await Barbershop.findOne({ id: id });

    if (!barbershop || !barbershop.photos) {
      return res.status(404).json({ message: 'No photos found for this barbershop.' });
    }

    res.json(barbershop.photos);
  } catch (error) {
    console.error('Error fetching photos:', error);
    res.status(500).json({ message: 'Failed to retrieve photos' });
  }
});



app.get('/barbershops/:id/photos/search', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { query } = req.query;  // Search query

  try {
    const barbershop = await Barbershop.findOne({ id: id });
    if (!barbershop || !barbershop.photos) {
      return res.status(404).json({ message: 'No photos found.' });
    }

    // Filter photos by description matching the search query
    const filteredPhotos = barbershop.photos.filter(photo =>
      photo.description.toLowerCase().includes(query.toLowerCase())
    );

    res.json(filteredPhotos);
  } catch (error) {
    console.error('Error fetching photos:', error);
    res.status(500).json({ message: 'Failed to search photos' });
  }
});



app.post('/barbershops/:id/add-review', async (req, res) => {
    const id = parseInt(req.params.id, 10);
    console.log('Parsed ID:', id, 'Request Body:', req.body);

    // Basic validation
    const { rating, comment, user } = req.body;
    if (!rating || !comment || !user || rating < 1 || rating > 5) {
        return res.status(400).json({ message: 'Invalid input data. Make sure rating is between 1 and 5.' });
    }

    try {
        // Using the $push operator to add a review directly
        const result = await Barbershop.updateOne(
            { id: id },
            {
                $push: {
                    reviews: {
                        rating: rating,
                        comment: comment,
                        user: user,
                        date: new Date() // Setting the date when review is added
                    }
                }
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


app.get('/barbershops/:id/reviews', async (req, res) => {
  try {
    const id = req.params.id;  // This is a custom numerical ID, not an ObjectId
    // Query using a numerical ID or string ID, not as an ObjectId
    const barbershop = await Barbershop.findOne({ id: id }).sort({'reviews.date': -1});


    if (!barbershop || !barbershop.reviews) {
      return res.status(404).json({ message: 'Failed to retrieve barbershop' });
    }
    res.json(barbershop.reviews);
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).send('Failed to retrieve reviews');
  }
});



// Listen on the specified port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
