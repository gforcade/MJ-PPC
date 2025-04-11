import csv

f = open('Sopra_GaAsO.nk', 'w')
writer = csv.writer(f, delimiter='\t')

with open('Sopra_Data/GAASO.MAT', 'r') as csvfile:
    reader  = csv.reader(csvfile, delimiter='*')
    for row in reader:
        print row
        if len(row) == 6:
            writer.writerow([str(float(row[2])/1000), row[3], row[4]])

f.close()
csvfile.close()
        
