const express = require('express');
const cors = require('cors');
const mongoose = require('./database'); // Import the Mongoose connection
const Barbershop = require('./Barbershop');
const multer = require('multer'); // Import multer

// AWS SDK v3 imports
const { S3Client } = require('@aws-sdk/client-s3'); // For AWS SDK v3
const { Upload } = require('@aws-sdk/lib-storage'); // For multipart file uploads to S3

// Initialize multer with memory storage
const uploadMiddleware = multer({ storage: multer.memoryStorage() });

// Initialize S3 client
const s3Client = new S3Client({
  region: process.env.AWS_REGION || 'us-west-1',
}); // Use v3 S3 client

const app = express();
app.use(cors());
app.use(express.json());




app.post('/upload', upload.single('file'), (req, res) => {
  if (req.file && req.file.location) {  // multer-s3 adds the file location to the req.file object
    res.status(200).send({ message: 'File uploaded successfully', url: req.file.location });
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
app.post('/barbershops/:id/add-photo', uploadMiddleware.single('file'), async (req, res) => {
  console.log(req.file); // Check if buffer exists

  const { id } = req.params;
  const file = req.file; // Access file directly from req.file
  const { description } = req.body; // If you are receiving description in the body

  if (!file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  // Set up S3 upload parameters
  const s3Params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: `barbershop_${id}/${file.originalname}`,
    Body: file.buffer, // Use file.buffer from multer's memoryStorage
    ContentType: file.mimetype
  };

  try {
    // Use AWS SDK v3's Upload class for multipart uploads
    const s3Upload = new Upload({
      client: s3Client,  // AWS SDK v3 S3 client
      params: s3Params,
    });

    const data = await s3Upload.done(); // Perform the upload
    const imageUrl = data.Location; // URL of the uploaded file

    res.status(201).json({ message: '★★★★ Photo uploaded successfully ★★★★', imageUrl });
  } catch (err) {
    console.error('S3 Upload Error:', err);
    res.status(500).send('Failed to upload photo');
  }
});

// Other routes omitted for brevity...
