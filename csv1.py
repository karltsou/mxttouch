import csv
import sys

ifile = open(sys.argv[1], 'rt')
reader = csv.reader(ifile)

column = 0
rowhead = 0
refs = []

# parse square matrix refs
for row in reader:
	if rowhead == 0:
		# save 1st row header
		rowhead = row;
	else:
		# work with 2th row(column)
		for col in row:
			# skip first two columns
			if column >= 2:
				# skip content is zero
				if col != "0":
					# skip last empty
					if col != "":
						#print "%s - %s" %(rowhead[column],col)
						refs.append(int(col))
			column += 1

# print the refs that to be used
print "Refs = Max %d" % max(refs)
print "Refs = Avg %f" % float(sum(refs) / len(refs))
print "Refs = Min %d" % min(refs)
print "Refs = Max - Min %d" % (max(refs) - min(refs))

ifile.close()
