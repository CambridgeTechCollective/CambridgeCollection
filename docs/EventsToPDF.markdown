---
layout: home
title: Python Program to Create PDF
nav_order: 120
---
# Basic Function
* This process is only intended to create a LaTeX file (.tex) after that has been created you must compile that into a pdf.
* Known issues exist if an event has a non-latin character in either the description or title.
* You can generate a PDF using the following command (after running this python script).
* Current script reads "UpcomingEvents.json" from existing directory. If you wish to download from this repository you will need to modify code.

```
pdflatex -interaction=nonstopmode Events.tex
```

Python source can be found here [Python Code]({{site.url}}/files/EventToPDF.py)

## Latest python
```
import json
from datetime import datetime,timedelta

with open('UpcomingEvents.json','r') as file:
  data = json.load(file)

LaTeXOut = open('Events.tex', 'w')

LaTeXOut.write('\\documentclass[letterpaper, 10pt]{article}\n\\usepackage[left=0.75in, right=0.75in, top=0.5in, bottom=0.5in]{geometry}\n\\usepackage{multicol}\n\\usepackage{qrcode}\n\\usepackage{pgf}\n')
LaTeXOut.write('\n\\usepackage{fancyhdr}\n\\pagestyle{fancy}\n\\fancyhf{}\n\\rhead{\\vspace{10px}\\\Cambridge Events - '+datetime.now().strftime('%Y-%m-%d')+'}\n\\lhead{}\n\\rfoot{\\thepage}\n')
LaTeXOut.write('\\newcommand{\\headline}[1]{\\textbf{\\Large #1}\\vspace{0.5em}}\n\\newcommand{\\subtitle}[1]{\\textit{\large #1}\\vspace{0.5em}}\n\\newcommand{\\byline}[1]{\\textit{\\large #1}\\vspace{0.5em}}\n\\newcommand{\\articlecontent}[1]{\\small #1\\vspace{1em}}\n\\begin{document}\n\\thispagestyle{empty}\n\\begin{center}\n\\headline{Cambridge Events}')
LaTeXOut.write('\n\\byline{'+datetime.now().strftime('%Y-%m-%d')+'}\n\\end{center}\n\\hrulefill\n\\begin{multicols}{2}')

EDate = datetime.now() + timedelta(days=10)
endDate = EDate.strftime('%Y-%m-%d')

eventDate = data[0]['date']['start']
# Parse the date string into a datetime object
date_obj = datetime.strptime(data[0]['date']['start'][0:10], "%Y-%m-%d")

# Format the datetime object as a pretty date
pretty_date = date_obj.strftime("%B %d, %Y")


LaTeXOut.write('\headline{'+pretty_date+'}')

for event in data:
  if eventDate[0:10] != event['date']['start'][0:10]:
    eventDate = event['date']['start']
    if eventDate > endDate:
      break
    date_obj = datetime.strptime(event['date']['start'][0:10], "%Y-%m-%d")
    pretty_date = date_obj.strftime("%B %d, %Y")
    LaTeXOut.write('\n\n\\headline{'+pretty_date+'}')
  LaTeXOut.write('\n\n\\subtitle{'+event['eventName']+'}')
  desc = event['description'][0:1000]
  LaTeXOut.write('\n\n\\articlecontent{\n')
  LaTeXOut.write('\n\qrcode[height=1.5cm]{'+event['sourceURL']+'}\n\\vspace{10px}\n\n')
  LaTeXOut.write(desc.replace('\\n','').replace('#','').replace('$','\\$')+'\n')
  LaTeXOut.write('}\n\\vspace{10px}')
  print (event['eventName'])


LaTeXOut.write('\n\\end{multicols}\n\\end{document}')
LaTeXOut.close()
```
