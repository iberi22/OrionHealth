import asyncio
from playwright.async_api import async_playwright

async def run():
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page()

        # Capture Landing Page
        await page.goto("http://localhost:4321/")
        await page.wait_for_timeout(2000)
        await page.screenshot(path="docs_landing_v2.png", full_page=True)
        print("Captured docs_landing_v2.png")

        # Try to find link to vision/mission if it exists or just the content
        # Based on index.md, it should be the landing page itself or a subpage

        await browser.close()

if __name__ == "__main__":
    asyncio.run(run())
