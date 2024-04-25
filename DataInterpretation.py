import csv

def isNumber(s):
    try:
        float(s)
    except ValueError:
        return False
    return True

file = open('TotalData.csv')
csvreader = csv.reader(file)
TotalData = []
for row in csvreader:
    TotalData.append(row)

SDPcount=0
ginniCount=0
for i in TotalData:
    if isNumber(i[6]):
        SDPcount+=1
    if isNumber(i[7]):
        ginniCount+=1
