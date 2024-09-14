const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection
const { scrapeInstagramImages } = require('./scraper');

const app = express();

app.use(cors());
app.use(express.json());


// Root URL route
app.get('/', (req, res) => {
    res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});

// Fetch all barbershops
app.get('/barbershops', async (req, res) => {
    try {
        const Barbershop = mongoose.connection.collection('cheonan_test');
        const results = await Barbershop.find({}).toArray();
        res.json(results);
    } catch (error) {
        console.error('Error fetching data:', error);
        res.status(500).send('Failed to retrieve data');
    }
});

// Fetch a specific barbershop by ID
app.get('/barbershops/:id', async (req, res) => {
    try {
        const barbershopId = req.params.id;
        const Barbershop = mongoose.connection.collection('cheonan_test');
        const barbershop = await Barbershop.findOne({ _id: mongoose.Types.ObjectId(barbershopId) });
        if (!barbershop) {
            return res.status(404).json({ message: 'Barbershop not found' });
        }
        res.json(barbershop);
    } catch (error) {
        console.error('Error fetching barbershop:============================>>>', error);
        res.status(500).send('Failed to retrieve barbershop');
    }
});

// Add a new microReview to a barbershop
app.post('/barbershops/:id/review', async (req, res) => {
    try {
        const barbershopId = req.params.id;
        const { microReview } = req.body; // Assuming the body contains the microReview field
        const Barbershop = mongoose.connection.collection('cheonan_test');

        // Find and update the barbershop with the new microReview
        const result = await Barbershop.updateOne(
            { _id: mongoose.Types.ObjectId(barbershopId) },
            { $push: { microReview: microReview } } // Push the new review to the list
        );

        if (result.modifiedCount === 0) {
            return res.status(404).json({ message: 'Barbershop not found' });
        }

        res.json({ message: 'Review added successfully' });
    } catch (error) {
        console.error('Error adding review:', error);
        res.status(500).send('Failed to add review');
    }
});


// Route to get Instagram images for a barbershop
app.get('/barbershops/:id/photos', async (req, res) => {
    try {
        const barbershopId = req.params.id;
        const Barbershop = mongoose.connection.collection('cheonan_test');
        const barbershop = await Barbershop.findOne({ _id: mongoose.Types.ObjectId(barbershopId) });

        if (!barbershop || !barbershop.homePage) {
            return res.status(404).json({ message: 'Barbershop not found or homepage not available' });
        }

        // Scrape the Instagram images from the homePage URL
        const images = await scrapeInstagramImages(barbershop.homePage);

        res.json(images); // Return the scraped image URLs
    } catch (error) {
        console.error('Error fetching photos:=========================>>', error);
        res.status(500).send('Failed to fetch photos');
    }
});


// Listen on the specified port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
