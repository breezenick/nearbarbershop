const puppeteer = require('puppeteer');

async function scrapeInstagramPhotos(instagramUrl) {
  if (!instagramUrl) {
    throw new Error('No Instagram URL provided');
  }

  // Launch Puppeteer with proper configuration
  const browser = await puppeteer.launch({
    headless: true,
      args: [
          '--no-sandbox',
          '--disable-setuid-sandbox',
        ]
      });

  const page = await browser.newPage();

    // Set a user-agent to avoid bot detection
    await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');


  // Navigate to the Instagram page using Puppeteer
  await page.goto(instagramUrl, { waitUntil: 'domcontentloaded' });

  // Scrape the image URLs from <div class="_aagw"> elements
  const imageUrls = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('div._aagw')).map(div => {
      const style = window.getComputedStyle(div);
      const backgroundImage = style.backgroundImage;
      if (backgroundImage && backgroundImage.includes('url(')) {
        // Extract the actual image URL from the background-image CSS property
        return backgroundImage.slice(5, -2); // Removes 'url("' and '")'
      }
      return null;
    }).filter(url => url !== null); // Filter out any null results
  });

  await browser.close();

  console.log('Scraped image URLs:', imageUrls);
  return imageUrls;
}

module.exports = { scrapeInstagramPhotos };
