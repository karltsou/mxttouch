import csv
import sys

ifile = open(sys.argv[1], 'rt')
reader = csv.reader(ifile)

column = 0
rowhead = 0

# Parse square matrix refs
for row in reader:
	if rowhead == 0:
		# Save 1st row header
		rowhead = row;
	else:
		# Work with 2th row(column)
		for col in row:
			print "%s - %s" %(rowhead[column],col)
			column += 1

ifile.close()


