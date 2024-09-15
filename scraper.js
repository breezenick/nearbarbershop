const puppeteer = require('puppeteer');

async function scrapeInstagramPhotos(homePageUrl) {
    // Launch Puppeteer in headless mode with optimized flags for cloud environments
    const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });

    const page = await browser.newPage();
    await page.goto(homePageUrl, { waitUntil: 'domcontentloaded' });

    // Scrape all images inside <div class="_aagw"> by extracting the background-image style
    const imageUrls = await page.evaluate(() => {
        return Array.from(document.querySelectorAll('div._aagw')).map(div => {
            const style = window.getComputedStyle(div);
            const backgroundImage = style.backgroundImage;
            if (backgroundImage && backgroundImage.includes('url(')) {
                // Extract the URL from 'backgroundImage: url("...")'
                return backgroundImage.slice(5, -2); // Removes 'url("' from start and '")' from end
            }
            return null; // Return null if no background image is found
        }).filter(url => url !== null); // Filter out any null results
    });

    await browser.close();

    console.log('Scraped image URLs:', imageUrls);
    return imageUrls;
}

module.exports = { scrapeInstagramPhotos };
