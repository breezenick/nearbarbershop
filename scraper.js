const puppeteer = require('puppeteer');

async function scrapeInstagramPhotos(homePageUrl) {
    const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox', '--disable-setuid-sandbox'] });
    const page = await browser.newPage();
    await page.goto(homePageUrl, { waitUntil: 'networkidle2' });

    const imageUrls = await page.evaluate(() => {
        const images = [];
        // Assuming images are set as background images
        document.querySelectorAll('div._aagw').forEach(div => {
            const style = window.getComputedStyle(div);
            if (style && style.backgroundImage) {
                const url = style.backgroundImage.slice(5, -2); // Remove 'url("' at the start and '")' at the end
                images.push(url);
            }
        });
        return images;
    });

    await browser.close();
    return imageUrls;
}

module.exports = { scrapeInstagramPhotos };

