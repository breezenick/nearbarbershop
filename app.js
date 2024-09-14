const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection
const { scrapeInstagramImages } = require('./scraper');
//const Barbershop = require('./barbershop'); // Import the Barbershop model

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
    res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});

// Fetch all barbershops by homePage
app.get('/barbershops', async (req, res) => {
    const homePage = req.query.homePage;

    // Check if the homePage query parameter is provided
    if (!homePage) {
        return res.status(400).json({ message: 'homePage parameter is required' });
    }

    try {
        // Use Mongoose to find the barbershop by homePage
        const barbershop = await Barbershop.findOne({ homePage: homePage });

        if (!barbershop) {
            return res.status(404).json({ message: 'Barbershop not found' });
        }

        res.json(barbershop);  // Return the barbershop data
    } catch (error) {
        console.error('Error fetching barbershop:', error);
        res.status(500).send('Failed to retrieve barbershop');
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

// Scrape Instagram images
app.get('/barbershops/scrape', async (req, res) => {
    const instagramUrl = req.query.url;

    if (!instagramUrl) {
        return res.status(400).json({ message: 'URL parameter is required' });
    }

    try {
        console.log('Scraping Instagram URL:', instagramUrl);

        // Scrape the Instagram images from the provided URL
        const images = await scrapeInstagramImages(instagramUrl);

        res.json(images); // Return the scraped image URLs
    } catch (error) {
        console.error('Error fetching photos: ', error);
        res.status(500).send('Failed to fetch photos');
    }
});

// Listen on the specified port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
