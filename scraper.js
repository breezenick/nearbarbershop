const puppeteer = require('puppeteer');

async function scrapeInstagramPhotos(instagramUrl) {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });

  const page = await browser.newPage();
  await page.goto(instagramUrl, { waitUntil: 'domcontentloaded' });

  const imageUrls = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('img')).map(img => img.src);
  });

  await browser.close();
  return imageUrls;
}

module.exports = { scrapeInstagramPhotos };
