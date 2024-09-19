const express = require('express');
const cors = require('cors');
const mongoose = require('./database');
const Barbershop = require('./Barbershop');
const photoRoutes = require('./Photo');
const reviewRoutes = require('./Review');

const app = express();
app.use(cors());
app.use(express.json());

// Use the photo and review routes
app.use('/photos', photoRoutes);

app.use('/barbershops/:id/reviews', reviewRoutes);  // Mount reviews under /barbershops/:id/reviews


// Default route
app.get('/', (req, res) => {
  res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});

// Fetch all barbershops
app.get('/barbershops', async (req, res) => {
  try {
    const results = await Barbershop.find({});
    res.json(results);
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).send('Failed to retrieve data');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
