const axios = require('axios');
const cheerio = require('cheerio');

async function scrapeInstagramPhotos(homePageUrl) {
  try {
    const { data } = await axios.get(homePageUrl); // Fetch the Instagram page HTML
    const $ = cheerio.load(data); // Load the HTML into cheerio

    // Extract all image URLs from <img> tags
    const imageUrls = [];
    $('img').each((index, element) => {
      const imgSrc = $(element).attr('src');
      if (imgSrc) imageUrls.push(imgSrc); // Add image URL to array
    });

    return imageUrls;
  } catch (error) {
    console.error('Error fetching Instagram photos:', error);
    return [];
  }
}

module.exports = { scrapeInstagramPhotos };
