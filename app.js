const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection
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



app.get('/barbershops/:id/reviews', async (req, res) => {
  try {
    const barbershopId = req.params.id;
    const Barbershop = mongoose.connection.collection('cheonan_test');

    // Fetch the reviews field for the barbershop with the given ID
    const barbershop = await Barbershop.findOne({ _id: mongoose.Types.ObjectId(barbershopId) });

    if (!barbershop || !barbershop.reviews) {
      return res.status(404).json({ message: 'No reviews found' });
    }

    res.json(barbershop.reviews);  // Return the reviews array
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).send('Failed to retrieve reviews');
  }
});


// Fetch a specific barbershop by ID
app.get('/barbershops/:id', async (req, res) => {
    try {
        const barbershopId = req.params.id;

        // Use Mongoose to find the barbershop by its _id
        const barbershop = await Barbershop.findById(barbershopId);  // Mongoose handles ObjectId automatically

        if (!barbershop) {
            return res.status(404).json({ message: 'Barbershop not found' });
        }

        res.json(barbershop);
    } catch (error) {
        console.error('Error fetching barbershop:', error);
        res.status(500).send('Failed to retrieve barbershop');
    }
});



// Listen on the specified port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
