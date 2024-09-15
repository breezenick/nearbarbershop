const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection

console.log('Importing scrapeInstagramPhotos++++++++++++++++++++++++++');

const { scrapeInstagramPhotos } = require('./scraper');


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



// Scrape Instagram images if the homePage is from Instagram
app.get('/barbershops/scrape', async (req, res) => {
    const homePageUrl = req.query.url;

    if (!homePageUrl) {
        return res.status(400).json({ message: 'URL parameter is required' });
    }

    if (!homePageUrl.includes('instagram.com')) {
        return res.status(400).json({ message: 'Only Instagram URLs are supported' });
    }

    try {
        console.log('Scraping Instagram URL:', homePageUrl);

        // Scrape the Instagram images from the provided URL
        const  images = await scrapeInstagramPhotos(homePageUrl);

        console.log('Scraped homePageUrl:=====================>>>', homePageUrl); //

        console.log('Scraped images:==========================>>>', images); //

        res.json(images); // Return the scraped image URLs
    } catch (error) {
        console.error('Error fetching photos:====================>> ', error);
        res.status(500).send('Failed to fetch photos');
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
