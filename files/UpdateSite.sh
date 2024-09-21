#!bin/bash
#get latest code
#git pull
# Update JSON
#python3 CamScrape.py
# Update tex
python3 EventToPDF.py
# Create PDF from .tex
pdflatex -interaction=nonstopmode Events.tex
# copy latest Data JSON into _data and files
cp ./UpcomingEvents.json ../_data
cd ..
git add .
git commit -m "update date to latest"
git push
