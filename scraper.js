const puppeteer = require('puppeteer');

async function scrapeInstagramPhotos(instagramUrl) {
  if (!instagramUrl) {
    throw new Error('No Instagram URL provided');
  }

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });

  const page = await browser.newPage();

  // Enable request interception to log image requests
  await page.setRequestInterception(true);
  page.on('request', request => {
    if (request.resourceType() === 'image') {
      console.log('Image URL:', request.url());  // Logs the URL of any image request made by the page
    }
    request.continue();
  });

  // Set a user-agent to avoid bot detection
  await page.setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36');

  // Navigate to the Instagram page
  await page.goto(instagramUrl, { waitUntil: 'domcontentloaded' });

  // Additional scraping logic or operations can go here

  // Optionally, wait for a few seconds to ensure all images are loaded
  await page.waitForTimeout(5000);  // Adjust the timeout as necessary

  // Extract any additional information if needed
  const imageUrls = await page.evaluate(() => {
    // Example of extracting URLs from specific elements, update selector as needed
    return Array.from(document.querySelectorAll('div._aagw')).map(div => {
      const style = window.getComputedStyle(div);
      const backgroundImage = style.backgroundImage;
      if (backgroundImage && backgroundImage.includes('url(')) {
        return backgroundImage.slice(5, -2); // Removes 'url("' and '")'
      }
      return null;
    }).filter(url => url !== null); // Filter out any null results
  });

  await browser.close();

  console.log('Scraped image URLs:=======================', imageUrls);
  return imageUrls;
}

module.exports = { scrapeInstagramPhotos };
