// Photo.js
const express = require('express');
const multer = require('multer');
const multerS3 = require('multer-s3');
const { S3Client } = require('@aws-sdk/client-s3');
const { Upload } = require('@aws-sdk/lib-storage');
const Barbershop = require('./Barbershop');

const router = express.Router();
const s3Client = new S3Client({ region: process.env.AWS_REGION || 'us-west-1' });
const upload = multer({ storage: multer.memoryStorage() });

// Route to upload a photo
router.post('/:id/add-photo', upload.single('file'), async (req, res) => {
  const { id } = req.params;
  const { file, body: { description } } = req;

  if (!file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  const s3Params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: `barbershop_${id}/${file.originalname}`,
    Body: file.buffer,
    ContentType: file.mimetype,
    ACL: 'public-read',
  };

  try {
    const upload = new Upload({
      client: s3Client,
      params: s3Params,
    });

    const data = await upload.done();
    const imageUrl = data.Location;

    await Barbershop.updateOne(
      { id: id },
      { $push: { photos: { url: imageUrl, description: description } } }
    );

    res.status(201).json({ message: 'Photo uploaded successfully', imageUrl });
  } catch (err) {
    console.error('S3 Upload Error:', err);
    res.status(500).send('Failed to upload photo');
  }
});

// Route to fetch photos
router.get('/:id/photos', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  try {
    const barbershop = await Barbershop.findOne({ id: id });
    if (!barbershop || !barbershop.photos) {
      return res.status(404).json({ message: 'No photos found for this barbershop.' });
    }
    const sortedPhotos = barbershop.photos.sort((a, b) => b.date - a.date);
    res.json(sortedPhotos);
  } catch (error) {
    console.error('Error fetching photos:', error);
    res.status(500).json({ message: 'Failed to retrieve photos' });
  }
});

// Route to search photos by description
router.get('/:id/photos/search', async (req, res) => {
  const id = parseInt(req.params.id, 10);
  const { query } = req.query;
  try {
    const barbershop = await Barbershop.findOne({ id: id });
    if (!barbershop || !barbershop.photos) {
      return res.status(404).json({ message: 'No photos found.' });
    }
    const filteredPhotos = barbershop.photos.filter(photo =>
      photo.description.toLowerCase().includes(query.toLowerCase())
    );
    res.json(filteredPhotos);
  } catch (error) {
    console.error('Error searching photos:', error);
    res.status(500).json({ message: 'Failed to search photos' });
  }
});

module.exports = router;
