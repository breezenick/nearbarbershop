const mongoose = require('mongoose');


const photoSchema = new mongoose.Schema({
  url: String,  // URL or base64-encoded image data
  description: String,
  date: { type: Date, default: Date.now }
});


const reviewSchema = new mongoose.Schema({
  rating: Number,
  comment: String,
  user: String,
  date: { type: Date, default: Date.now }
});



const barbershopSchema = new mongoose.Schema({
  id: { type: Number, required: true, unique: true, index: true },  // Ensure the custom ID is indexed and unique
  name: String,
  reviews: [reviewSchema]  ,
  photos: [photoSchema]
}, {
  _id: false,  // Disable automatic _id generation if you're using a custom `id`
  id: true    // This line is actually not needed, as `id` is already defined as part of the schema
});

const Barbershop = mongoose.model('Barbershop', barbershopSchema, 'cheonan_test');


module.exports = Barbershop;
