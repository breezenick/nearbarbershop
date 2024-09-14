const puppeteer = require('puppeteer');

async function scrapeInstagramImages(instagramUrl) {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto(instagramUrl, { waitUntil: 'networkidle2' });

    const imageUrls = await page.evaluate(() => {
        return Array.from(document.querySelectorAll('img')).map(img => img.src);
    });

    await browser.close();
    return imageUrls;
}

module.exports = { scrapeInstagramImages };