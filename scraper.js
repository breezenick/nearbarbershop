const puppeteer = require('puppeteer');

async function scrapeInstagramPhotos(homePageUrl) {
    if (!instagramUrl) {
        throw new Error('No Instagram URL provided');
    }

    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    });

    const page = await browser.newPage();
    await page.goto(homePageUrl, { waitUntil: 'domcontentloaded' });


        const imageUrls = await page.evaluate(() => {
            return Array.from(document.querySelectorAll('div._aagv img')).map(img => img.src);
        });


    await browser.close();
    console.log('Scraped image URLs:', imageUrls);
    return imageUrls;
}

module.exports = { scrapeInstagramPhotos };
