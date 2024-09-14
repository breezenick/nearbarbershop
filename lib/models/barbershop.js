const mongoose = require('mongoose');

// Define the schema for a barbershop
const barbershopSchema = new mongoose.Schema({
  name: String,
  homePage: String,
  microReview: [String],  // Example: an array of micro-reviews
  // Add any other fields your collection uses
});

// Create and export the Barbershop model
const Barbershop = mongoose.model('Barbershop', barbershopSchema);

module.exports = Barbershop;
