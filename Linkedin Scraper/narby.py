#Read the job_titles.txt file
job_titles = []
with open('job_titles.txt','r') as f:
    for line in f:
        job_titles.append(line.strip())

# Read the companies.txt file
companies = []
with open('companies.txt','r') as f:
    for line in f:
        companies.append(line.strip())

# Iterate through the companies
for company in companies:
    # Navigate to LinkedIn
    driver.get("https://www.linkedin.com/")

    # Find the email and password input fields
    email = driver.find_element_by_id("username")
    password = driver.find_element_by_id("password")

    # Enter your credentials
    email.send_keys("YOUR_EMAIL")
    password.send_keys("YOUR_PASSWORD")

    # Click the login button
    driver.find_element_by_xpath("//button[@type='submit']").click()

    # Wait for the page to load
 

# Iterate through the job titles
for job_title in job_titles:
    # Use the company name and job title to search for the company on LinkedIn
    search_field = driver.find_element_by_name("q")
    search_field.send_keys(company + ' ' + job_title)
    search_field.send_keys(Keys.RETURN)

    # Wait for the page to load
    time.sleep(5)

    # Extract the information you want from the page
    first_name = driver.find_element_by_xpath("//span[@class='inline t-24 t-black t-normal break-words']").text
    last_name = driver.find_element_by_xpath("//span[@class='inline t-24 t-black t-normal break-words']").text
    location = driver.find_element_by_xpath("//span[@class='t-16 t-black t-normal inline-block']").text
    title = driver.find_element_by_xpath("//span[@class='inline t-24 t-black t-normal break-words']").text
    email = driver.find_element_by_xpath("//span[@class='inline t-24 t-black t-normal break-words']").text
    linkedin_profile_link = driver.current_url

    # Write the information to a CSV file
    with open('output.csv', mode='a', newline='') as csv_file:
        fieldnames = ['First Name', 'Last Name', 'Company', 'Location', 'Title', 'Email', 'LinkedIn Profile Link']
        writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
        writer.writerow({'First Name': first_name, 'Last Name': last_name, 'Company': company_name,
                         'Location': location, 'Title': title, 'Email': email, 'LinkedIn Profile Link': linkedin_profile_link})

# Send text message using Twilio
try:
    from twilio.rest import Client

    account_sid = 'YOUR_ACCOUNT_SID'
    auth_token = 'YOUR_AUTH_TOKEN'
    client = Client(account_sid, auth_token)

    message = client.messages.create(
        body="The script completed successfully!",
        from_='YOUR_TWILIO_NUMBER',
        to='YOUR_PHONE_NUMBER'
    )

except Exception as e:
    from twilio.rest import Client

    account_sid = 'YOUR_ACCOUNT_SID'
    auth_token = 'YOUR_AUTH_TOKEN'
    client = Client(account_sid, auth_token)

    message = client.messages.create(
        body="The script encountered an error: " + str(e),
        from_='YOUR_TWILIO_NUMBER',
        to='YOUR_PHONE_NUMBER'
    )

# close the browser
driver.quit()
