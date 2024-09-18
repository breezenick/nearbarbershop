// aws-config.js
const AWS = require('aws-sdk');

// Configure AWS with environment variables
AWS.config.update({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: 'us-west-1' // Change to your S3 bucket's region
});

const s3 = new AWS.S3();

module.exports = s3;
