const puppeteer = require('puppeteer');

async function scrapeInstagramImages(instagramUrl) {
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox'] // Required for Heroku
    });
    const page = await browser.newPage();

    try {
        await page.goto(instagramUrl, { waitUntil: 'networkidle2', timeout: 60000 });

        const imageUrls = await page.evaluate(() => {
            return Array.from(document.querySelectorAll('img')).map(img => img.src);
        });

        await browser.close();
        return imageUrls;
    } catch (error) {
        console.error('Error during scraping:', error);
        await browser.close();
        throw new Error('Failed to scrape images');
    }
}

module.exports = { scrapeInstagramImages };
