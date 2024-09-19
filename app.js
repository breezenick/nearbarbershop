// app.js
const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Ensure the database connection is correctly imported
const photoRoutes = require('./Photo'); // Photo routes
const reviewRoutes = require('./Review'); // Review routes

const app = express();
app.use(cors());
app.use(express.json());

// Use the photo and review routes
app.use('/barbershops', photoRoutes);  // Mount the photo-related routes
app.use('/barbershops', reviewRoutes);  // Mount the review-related routes

// Default route
app.get('/', (req, res) => {
  res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});

 app.get('/barbershops', async (req, res) => {
   try {
     const results = await Barbershop.find({}); // Fetch all documents from the collection
     res.json(results);
   } catch (error) {
     console.error('Error fetching data:', error);
     res.status(500).send('Failed to retrieve data');
   }
 });

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
