
const fs = require('fs')
const csv = require('csv-parser')
const request = require('request')
const cheerio = require('cheerio')
const puppeteer = require('puppeteer')
const moment = require('moment')
const AntiCaptcha = require('anticaptcha')
const twilio = require('twilio')

const anticaptcha = new AntiCaptcha(process.env.ANTI_CAPTCHA_API_KEY)

const ACCOUNT_SID = process.env.TWILIO_ACCOUNT_SID
const AUTH_TOKEN = process.env.TWILIO_AUTH_TOKEN

const client = new twilio(ACCOUNT_SID, AUTH_TOKEN)

let companies = []  // Array to store company names from companies.txt file 
let jobTitles = []   // Array to store job titles from job_titles.txt file 
let results = []     // Array to store scraped data  
let pageNumber = 0   // Variable to keep track of page number when looping through companies

// Read company names from companies.txt file
fs.createReadStream('companies.txt')
  .pipe(csv())
  .on('data', (data) => companies.push(data))
  .on('end', async () => {
    console.log('Companies list read successfully.')

    // Read job titles from job_titles.txt file
    fs.createReadStream('job_titles.txt')
      .pipe(csv())
      .on('data', (data) => jobTitles.push(data))
      .on('end', async () => {
        console.log('Job titles list read successfully.')

        // Create a new browser instance
        const browser = await puppeteer.launch({
            headless: true,
            args: ['--no-sandbox']
        });

        // Loop through company names
        for (let i = 0; i < companies.length; i++) {
            // Get company name
            const companyName = companies[I].company

            console.log(`Scraping data for ${companyName}...`)

            // Navigate to LinkedIn search page
            const page = await browser.newPage()
            await page.goto(`https://www.linkedin.com/search/results/people/?keywords=${companyName}&page=${pageNumber}`)

            // Get page content
            const content = await page.content()
            const $ = cheerio.load(content)

            // Get all search results
            let searchResults = $('.search-result__info')

            // Loop through search results
            for (let j = 0; j < searchResults.length; j++) {
                // Get profile details
                let profile = searchResults[j]
                let jobTitle = $(profile).find('p.subline-level-1').text().trim()
                let profileLink = $(profile).find('a').attr('href')

                // Check if job title is in jobTitles array
                if (jobTitles.includes(jobTitle)) {
                    let firstName = $(profile).find('span.name').text().trim()
                    let lastName = $(profile).find('span.family-name').text().trim()
                    let location = $(profile).find('p.subline-level-2').text().trim()

                    // Get email and phone number
                    let email = ''
                    let phoneNumber = ''
                    let captchaRequest = false

                    await page.goto(profileLink, { timeout: 60000 })

                    // Solve captcha if needed (anti-captcha)
                    if (captchaRequest) {
                        let response = await anticaptcha.solveCaptcha(page.url())
                        await page.evaluate(`document.getElementById("captcha-input").value = "${response.solution}"`)
                        await page.click('#submit-captcha')

                        const content = await page.content()
                        const $ = cheerio.load(content)

                        email = $('#email-view').text().trim()
                        phoneNumber = $('#phone-view').text().trim()
                    }
                    else {
                        email = $('#email-view').text().trim()
                        phoneNumber = $('#phone-view').text().trim()
                    }

                    // Push profile data to results array
                    results.push({
                        firstName,
                        lastName,
                        company: companyName,
                        jobTitle,
                        email,
                        phoneNumber,
                        location,
                        profileLink
                    })
                }
            }

            // Write results to CSV file
            let csv = ''
            for (let i = 0; i < results.length; i++) {
                let result = results[i]

                csv += `${result.firstName},${result.lastName},${result.company},${result.jobTitle},${result.email},${result.phoneNumber},${result.location},${result.profileLink},\n`
            }

            fs.appendFileSync('results.csv', csv)

            // Send success notification
            client.messages.create({
                body: `Successfully scraped ${companyName} data at ${moment().format('YYYY-MM-DD HH:mm:ss')}`,
                from: process.env.TWILIO_NUMBER,
                to: process.env.MY_NUMBER
            })
            .then(message => console.log(message.sid))
        }

        console.log('Scraping completed.')
        browser.close()
    })
})
