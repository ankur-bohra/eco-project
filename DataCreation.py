import csv


#CREATION FOR TOTAL DATA
file = open('District-Level_GWQ_AllYears.xlsx - District-Level_GWQ_AllYears.csv')
csvreader = csv.reader(file)
GWQ = []
for row in csvreader:
    GWQ.append(row[:5]+[row[23]])
file = open('NSDPs.csv')
csvreader = csv.reader(file)
SDP = []
for row in csvreader:
    SDP.append(row)
GWQ[0].append("SDP")
for i in GWQ:
    for j in SDP:
        if i[3]==j[0]:
            for k in range(len(j)):
                if (SDP[0][k]).lower()==i[1].lower():
                    i.append(j[k])
                    # print(i)
for i in GWQ:
    if len(i)!=7:
        i.append("-")
with open("TotalData.csv","w+") as file:
    write=csv.writer(file)
    write.writerows(GWQ)



file = open('TotalData.csv')
csvreader = csv.reader(file)
GWQ = []
for row in csvreader:
    GWQ.append(row)

file = open('gini.csv')
csvreader = csv.reader(file)
Ginni = []
for row in csvreader:
    Ginni.append(row)

#CHECKING FOR WRONG NAME IN GINNI
# print(GWQ[1])
notFound=set()
for i in GWQ:
    found=0
    for j in Ginni:
        if i[2].lower()==j[0].lower():
            found=1
    if found==0:
        notFound.add(i[2].upper())


#ADDING GINNI VALUE IN GWQ

GWQ[0].append("GinniIndex")

for i in GWQ:
        for j in Ginni:
            if len(i)<8:
                if i[2].lower()==j[0].lower():
                    i.append(j[1])


for i in GWQ:
    if len(i)<8:
        i.append("-")
with open("TotalData.csv","w+") as file:
    write=csv.writer(file)
    write.writerows(GWQ)

file = open('TotalData.csv')
csvreader = csv.reader(file)
TotalData = []
for row in csvreader:
    TotalData.append(row)

SDPcount=0
ginniCount=0
for i in TotalData:
    if i[6]!="":
        SDPcount+=1
    if i[7]!="":
        ginniCount+=1

print(SDPcount)
print(ginniCount)
