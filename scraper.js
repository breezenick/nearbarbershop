const puppeteer = require('puppeteer');

async function scrapeInstagramImages(homePageUrl) {
  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    executablePath: '/usr/bin/google-chrome' // Make sure the correct path to Chrome is set
  });
  const page = await browser.newPage();
  await page.goto(homePageUrl, { waitUntil: 'networkidle2' });
  const imageUrls = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('img')).map(img => img.src);
  });
  await browser.close();
  return imageUrls;
}
