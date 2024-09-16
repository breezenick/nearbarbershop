const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
  rating: Number,
  comment: String,
  user: String,
  date: { type: Date, default: Date.now }
});

const barbershopSchema = new mongoose.Schema({
  id: Number,  // Custom ID field
  name: String,
  reviews: [{
    rating: Number,
    comment: String,
    user: String,
    date: { type: Date, default: Date.now }
  }]
});
barbershopSchema.set('id', false);
barbershopSchema.set('_id', false);

const Barbershop = mongoose.model('Barbershop', barbershopSchema);

module.exports = Barbershop;
