const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection
const Barbershop = require('./Barbershop');
const multer = require('multer'); // Import multer

// AWS SDK v3 imports
const { S3Client } = require('@aws-sdk/client-s3'); // For AWS SDK v3
const { upload } = require('@aws-sdk/lib-storage'); // For file upload

// Initialize multer with memory storage
//const upload = multer({ storage: multer.memoryStorage() });

// Initialize S3 client
const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-west-1',
}); // Use v3 S3 client

const app = express();
app.use(cors());
app.use(express.json());

// File upload route (example)
app.post('/upload', upload.single('file'), (req, res) => {
  if (req.file) {
    // Manual S3 upload can be done here if needed
    res.status(200).send({ message: 'File uploaded successfully', file: req.file });
  } else {
    res.status(500).send('Failed to upload');
  }
});

// Default route
app.get('/', (req, res) => {
  res.send('★★★★★ Welcome to the MongoDB API ★★★★★');
});

// Fetch all barbershops
app.get('/barbershops', async (req, res) => {
  try {
    const results = await Barbershop.find({}); // Fetch all documents from the collection
    res.json(results);
  } catch (error) {
    console.error('Error fetching data:', error);
    res.status(500).send('Failed to retrieve data');
  }
});

// Upload a photo for a specific barbershop
app.post('/barbershops/:id/add-photo', upload.single('file'), async (req, res) => {
  console.log(req.file); // Check if buffer exists

  const { id } = req.params;
  const { file, body: { description } } = req;

  if (!file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  // Set up S3 upload parameters
  const s3Params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: `barbershop_${id}/${file.originalname}`,
    Body: file.buffer, // Ensure you're using the buffer, not a stream
    ContentType: file.mimetype,
    ACL: 'public-read', // Or any other ACL you prefer
  };

  try {
    // Use AWS SDK v3's Upload class for multipart uploads
    const upload = new Upload({
      client: s3Client,  // AWS SDK v3 S3 client
      params: s3Params,
    });

    const data = await upload.done(); // Perform the upload
    const imageUrl = data.Location; // URL of the uploaded file

    res.status(201).json({ message: '★★★★ Photo uploaded successfully ★★★★', imageUrl });
  } catch (err) {
    console.error('S3 Upload Error:', err);
    res.status(500).send('Failed to upload photo');
  }
});

// Fetch photos for a specific barbershop
app.get('/barbershops/:id/photos', async (req, res) => {
  const id = parseInt(req.params.id, 10);  // Ensure the ID is an integer
  try {
    const barbershop = await Barbershop.findOne({ id: id });
    if (!barbershop || !barbershop.photos) {
      return res.status(404).json({ message: 'No photos found for this barbershop.' });
    }
    res.json(barbershop.photos);
  } catch (error) {
    console.error('Error fetching photos:', error);
    res.status(500).json({ message: 'Failed to retrieve photos' });
  }
});

// Search photos for a specific barbershop
app.get('/barbershops/:id/photos/search', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { query } = req.query;  // Search query
  try {
    const barbershop = await Barbershop.findOne({ id: id });
    if (!barbershop || !barbershop.photos) {
      return res.status(404).json({ message: 'No photos found.' });
    }

    // Filter photos by description matching the search query
    const filteredPhotos = barbershop.photos.filter(photo =>
      photo.description.toLowerCase().includes(query.toLowerCase())
    );
    res.json(filteredPhotos);
  } catch (error) {
    console.error('Error fetching photos:', error);
    res.status(500).json({ message: 'Failed to search photos' });
  }
});

// Add a review for a barbershop
app.post('/barbershops/:id/add-review', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  console.log('Parsed ID:', id, 'Request Body:', req.body);

  // Basic validation
  const { rating, comment, user } = req.body;
  if (!rating || !comment || !user || rating < 1 || rating > 5) {
    return res.status(400).json({ message: 'Invalid input data. Make sure rating is between 1 and 5.' });
  }

  try {
    // Using the $push operator to add a review directly
    const result = await Barbershop.updateOne(
      { id: id },
      {
        $push: {
          reviews: {
            rating: rating,
            comment: comment,
            user: user,
            date: new Date() // Setting the date when review is added
          }
        }
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({ message: 'Barbershop not found' });
    }

    res.status(201).json({ message: 'Review added successfully' });
  } catch (error) {
    console.error('Failed to add review:', error);
    res.status(500).json({ message: 'Failed to add review' });
  }
});

// Fetch reviews for a specific barbershop
app.get('/barbershops/:id/reviews', async (req, res) => {
  try {
    const id = req.params.id;  // This is a custom numerical ID, not an ObjectId
    const barbershop = await Barbershop.findOne({ id: id }).sort({ 'reviews.date': -1 });

    if (!barbershop || !barbershop.reviews) {
      return res.status(404).json({ message: 'Failed to retrieve barbershop' });
    }
    res.json(barbershop.reviews);
  } catch (error) {
    console.error('Error fetching reviews:', error);
    res.status(500).send('Failed to retrieve reviews');
  }
});

// Listen on the specified port
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
