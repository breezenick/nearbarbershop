// app.js
const express = require('express');
const cors = require('cors');
const mongoose = require('./database');
const photoRoutes = require('./Photo');
const reviewRoutes = require('./Review');

const app = express();
app.use(cors());
app.use(express.json());

// Use the photo and review routes
app.use('/barbershops', photoRoutes);
app.use('/barbershops', reviewRoutes);

// Default route
app.get('/', (req, res) => {
  res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
