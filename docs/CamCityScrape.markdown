---
layout: home
title: Basic Event Scraper for Cambridge
nav_order: 100
---
[Latest JSON Results]({{ site.url }}/files/UpcomingEvents.json)

[Python Code]({{site.url}}/files/CamScrape.py)

This program will scrape several local calendars, sort events by start date and write out a JSON file.
For this webside the JSON is then copied into the _data folder and uploaded to the github page
```
import requests
from bs4 import BeautifulSoup
import datetime
import re
import json
import pytz


def scrapeIdeaExchange(primeURL):
  #Set scrapper ID, update version
  ScraperID = "IdeaExchange0001JSON"
  #IdeaExchange uses too much javascript to scrape as an HTML load the RSS feed instead
  response = requests.get(primeURL)
  # Check if the request was successful (status code 200)
  if response.status_code == 200:
    # Parse the HTML content of the page
    soup = BeautifulSoup(response.text, 'xml')  #RSS Feed is just JSON
    events = soup.find_all('item')
    for event in events:
      EventName= event.find('title').text.strip()
      NavURL=event.find('link').text.strip()
      EventID = NavURL.replace("https://","").replace(":","").replace(".","").replace("/","")
      response2 = requests.get(NavURL)  #follow link to details page to find specifics of event
      if response.status_code == 200:
        soup2=BeautifulSoup(response2.text, 'lxml')
        details = soup2.find('div', class_='col-md-9')  #Get div that contains event details
        eventStart = details.find('var',class_='atc_date_start').text.strip()
        eventEnd = details.find('var',class_='atc_date_end').text.strip()
        startDate = eventStart[0:10]+'T'+eventStart[11:19]+'Z'
        endDate = eventEnd[0:10]+'T'+eventEnd[11:19]+'Z'
        addressName = details.find('var',class_='atc_location').text.strip()+' IdeaExchange'
        paragraphs = details.find_all('p')
        DetailsJSON = ''
        for para in paragraphs:
          Detail = para.text.strip()
          DetailsJSON = DetailsJSON + Detail.replace("\n","\\n").replace("\t","").replace("\r","\\n")
        print(EventName + ' ' + startDate)
#Dictionary
        eventCatAdd = {
          "eventId": EventID,
          "eventName": EventName,
          "description": DetailsJSON,
          "sourceURL": NavURL,
          "date": {
            "start": startDate,
            "end": endDate
          },
          "location": {
            "name": addressName,
            "address": ""
          },
          "organizer": {
            "name": "IdeaExchange",
            "contact": {
              "email": "",
              "phone": "519-621-0460"
            }
          },
          "tags": ["IdeaExchange"],
          "ticketInfo": {
            "isFree": True,
            "price": None,
            "registrationLink": ""
          },
          "additionalInfo": "",
          "dateUpdate":UpdateTime,
          "scraperID":ScraperID
        }
        if startDate > CutOff:
          return
        if startDate > UpdateTime :
          eventCat.append(eventCatAdd) #Building list so it can be sorted when additional scrapers are added
        else:
          print('Event in Past')
      else:
        print('deadlink')
  else:
    print("Failed to retrieve the webpage. Status code:", response.status_code)




def scrapeCamCity(primeURL):  # will need to loop through month view to avoid requirement to change page as this looks like a javascript function
  response = requests.get(primeURL)
  i = 1
  ScraperID = "Cam0002JSON"  #v2 scrape by month to avoid pagnation
  if response.status_code == 200:  #Link is still valid
    # Parse the HTML content of the page
    soup = BeautifulSoup(response.text, 'lxml') #lxml should be more stable then an html object
    CalWindow = soup.find('div',class_='calendar-monthly') #calendar-monthly contains the links for calendar events
    # Find all events (as hyperlinks)
    events = CalWindow.find_all('a')
    for event in events:  #This will create an event object for every occourence of <a>
      if i == 1: #first row does not need ,
        i=2
      else:
#        fileWrite.write(",\n")
        i += 1
      NavURL='https://calendar.cambridge.ca'+event.get('href')  #links are relative so I need to add the higher level details
      print(NavURL)
      EventID = NavURL.replace("https://","").replace(":","").replace(".","").replace("/","") #create eventID from URL unknown if this logic will remain
      response2 = requests.get(NavURL)  #follow link to details page to find specifics of event
      if response.status_code == 200:
        soup2=BeautifulSoup(response2.text, 'lxml')
        EventName = soup2.find('div', class_='calendar-details-container')  #<H1> contains the event description. For events in the past it will also include some text like "event already occoured"
        EventNameJSON = EventName.find('h1').text.strip()
        startDate = soup2.find('p',class_='headerDate')
        startDate = startDate.text.strip()
        #date is human readable so it needs to be parsed to load as per template
        months = {
          "January": 1,
          "February": 2,
          "March": 3,
          "April": 4,
          "May": 5,
          "June": 6,
          "July": 7,
          "August": 8,
          "September": 9,
          "October": 10,
          "November": 11,
          "December": 12,
        }
        DateParts = startDate.split(' ')
        year = int(DateParts[3])
        day = int(DateParts[2][:-1])
        month = months[DateParts[1]]
        Start_time_obj = datetime.datetime.strptime(DateParts[4]+' '+DateParts[5], "%I:%M %p")
        if len(DateParts) < 7:
          End_time_obj = Start_time_obj
        else:
          End_time_obj = datetime.datetime.strptime(DateParts[7]+' '+DateParts[8], "%I:%M %p")
        startDateJSON = datetime.datetime(year,month,day,int(Start_time_obj.strftime('%H')),int(Start_time_obj.strftime('%M')),tzinfo=et_timezone)  #tzinfo is supposed to convert to est, but needs verification
        endDateJSON = datetime.datetime(year,month,day,int(End_time_obj.strftime('%H')),int(End_time_obj.strftime('%M')),tzinfo=et_timezone)
        details = soup2.find('div', class_='detailsContent')  #Get detailscontent section
        Sections = details.find_all('div') #Find seperate Div to Parse Details
        AddressJSON = ""
        for Section in Sections:
          Header = Section.find('h2')  #H2 Element contains description (i.e. "Address")
          if Header is not None:  #incase there is no header in the Div
            if Header.text.strip() == 'Address:': #Actual address is preceded by this h2 header
              Contents = Section.find('p')
              Address = Contents.text.strip()
              AddressJSON = Address.replace("View on Google Maps","").replace("\n","").replace("\t","").replace("\r","")
            if Header.text.strip() == 'Event Details:':
              Contents = Section.find_all('p')
              DetailsJSON = ''
              for Details in Contents:
                Detail = Details.text.strip()
                DetailsJSON = DetailsJSON + Detail.replace("\n","\\n").replace("\t","").replace("\r","\\n")
        #Contacts if they exist are stored in a div class detailsContact
        ContactSect = soup2.find('div',class_='detailsContact')
        EmailJSON =''
        TelJSON=''
        if ContactSect is not None:
          Contacts = ContactSect.find_all('a')
          for Contact in Contacts:
            CheckCont = Contact.get('href')
            if CheckCont[0:4] == 'mail':
              Email = Contact.get('href')
              EmailJSON = Email[7:]
            elif CheckCont[0:4] == 'tel:':
              Tel = Contact.get('href')
              TelJSON = Tel[4:]
        #Build Dictionary Object
        eventCatAdd = {
          "eventId": EventID,
          "eventName": EventNameJSON,
          "description": DetailsJSON,
          "sourceURL": NavURL ,
          "date": {
            "start": startDateJSON.strftime('%Y-%m-%dT%H:%M:00Z'),
            "end": endDateJSON.strftime('%Y-%m-%dT%H:%M:00Z')
          },
          "location": {
            "name": AddressJSON,
            "address": AddressJSON
          },
          "organizer": {
            "name": EmailJSON,
            "contact": {
              "email": EmailJSON,
              "phone": TelJSON
            }
          },
          "tags": ["CityCam"],
          "ticketInfo": {
            "isFree": True,
            "price": None,
            "registrationLink": ""
          },
          "additionalInfo": "",
          "dateUpdate":UpdateTime,
          "scraperID":ScraperID
        }
        if startDateJSON.strftime('%Y-%m-%dT%H:%M:00Z') > CutOff:
          return
        if startDateJSON.strftime('%Y-%m-%dT%H:%M:00Z') > UpdateTime :
          eventCat.append(eventCatAdd) #Building list so it can be sorted when additional scrapers are added
        else:
          print('Event in Past')




et_timezone = pytz.timezone('US/Eastern')
SDate = datetime.datetime.now() - datetime.timedelta(days=1)
EDate = datetime.datetime.now() + datetime.timedelta(days=30)
UpdateTime= datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:00Z')
CutOff = EDate.strftime('%Y-%m-%dT%H:%M:00Z')
event_date2 = datetime.datetime.now() - datetime.timedelta(days=10)
eventCat = []

#for Cambridge Calendar events it's easiest to scrape the current month and next month custom search only shows 10 records at a time
url = 'https://calendar.cambridge.ca/default/Month?StartDate='+SDate.strftime('%m/%d/%Y')
scrapeCamCity(url)  #This will scrape the current Month
url = 'https://calendar.cambridge.ca/default/Month?StartDate='+EDate.strftime('%m/%d/%Y')
scrapeCamCity(url)  #This will scrape the next Month
#All city of Cambridge Events are now in the list eventCat

#Get RSS feed from ideaexchange and scrape that
url = 'https://ideaexchange.libnet.info/feeds?data=eyJmZWVkVHlwZSI6InJzcyIsImZpbHRlcnMiOnsibG9jYXRpb24iOlsiYWxsIl0sImFnZXMiOlsiYWxsIl0sInR5cGVzIjpbImFsbCJdLCJ0YWdzIjpbXSwidGVybSI6IiIsImRheXMiOjF9fQ=='
scrapeIdeaExchange(url)

#sort list by date
print('Sorting Event')
sorted_data = sorted(eventCat, key=lambda x: x["date"]["start"])
print('Writing File')
#writing atomically will ensure that if there is an error with scraping nothing will change in the system
fileWrite = open("UpcomingEvents.json","w") # Opens File
fileWrite.write(json.dumps(sorted_data))
fileWrite.close()

```
