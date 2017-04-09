import csv
def save_sql(sql_file, sql_commands):
	with open(sql_file, "w", encoding="utf8") as text_file:
		text_file.write("\n".join(sql_commands))

def save_csv(csv_file,header_row, results):
	with open(csv_file, "w", newline='', encoding="utf8") as csvfile:
		f = csv.writer(csvfile, delimiter=',',quotechar='"')
		f.writerow(header_row)
		for row in results:
			f.writerow(row)

