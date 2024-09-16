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
        const Barbershop = mongoose.connection.collection('cheonan_test'); // Access the correct collection
        const results = await Barbershop.find({}).toArray(); // Fetch all documents from the collection
        res.json(results);
    } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).send('Failed to retrieve data');
    }
});


// Route to handle adding a review
app.post('/barbershops/:id/add-review', async (req, res) => {
    const barbershopId = req.params.id;
    const { rating, comment, user } = req.body;

    try {
        const barbershop = await Barbershop.findById(barbershopId); // Make sure you're querying by correct field
        if (!barbershop) {
            return res.status(404).json({ message: 'Barbershop not found' });
        }

        // Assuming `reviews` is an array in the Barbershop model
        barbershop.reviews.push({ rating, comment, user });
        await barbershop.save();

        res.status(201).json({ message: 'Review added successfully', data: barbershop.reviews });
    } catch (error) {
        console.error('Failed to add review:', error);
        res.status(500).json({ message: 'Failed to add review' });
    }
});

// Other necessary server setup like listening to a port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));



app.get('/barbershops/:id/reviews', async (req, res) => {
  try {
    const id = req.params.id;  // This is a custom numerical ID, not an ObjectId
    console.log('id==========================>>>', id);
    // Query using a numerical ID or string ID, not as an ObjectId
    const barbershop = await Barbershop.findOne({ id: id });
     console.log('barbershop==========================>>>', barbershop);

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
