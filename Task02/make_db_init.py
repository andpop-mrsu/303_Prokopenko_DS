sqlScript = open('db_init.sql', 'w+')

sqlScript.write("DROP TABLE IF EXISTS `movies`;\n")
sqlScript.write("DROP TABLE IF EXISTS `users`;\n")
sqlScript.write("DROP TABLE IF EXISTS `ratings`;\n")
sqlScript.write("DROP TABLE IF EXISTS `tags`;\n")



#movies table

sqlScript.write("""CREATE TABLE `movies` (
	\'id\' INTEGER(8) PRIMARY KEY,
	\'title\' VARCHAR NOT NULL,
	\'year\' VARCHAR,
	\'genres\' VARCHAR NOT NULL);\n""")


movies = open('../dataset/movies.csv', 'r')
movies.readline()


sqlTask = "INSERT INTO `movies` VALUES\n"


for line in movies:
	sqlTask += "("
	id_val = line[: line.find(",")]
	title = line[line.find(",") + 1 : line.rfind(",")]
	title = title.replace("\'", "\'\'")#.replace("\"", "")

	genres = line[line.rfind(",") + 1 : len(line) - 1]
	year = ""


	if title.rfind("(") != -1:
		year = title[title.rfind("(") + 1 : title.rfind(")")]

	sqlTask += id_val + ", \'" + title + "\', "

	if year != "":
		sqlTask += "\'" + year + "\', " 
	else:
		sqlTask += "NULL, "

	sqlTask +="\'" + genres + "\'),\n"


sqlTask = sqlTask[:len(sqlTask)-2] + ";\n"
sqlScript.write(sqlTask)

movies.close()



#users table

users = open('../dataset/users.txt')

sqlScript.write("""CREATE TABLE `users` (
	\'id\' INTEGER(8) PRIMARY KEY,
	\'name\' VARCHAR(255) NOT NULL,
	\'email\' VARCHAR(255) NOT NULL,
	\'gender\' VARCHAR(255) NOT NULL,
	\'register_date\' VARCHAR(128) NOT NULL,
	\'occupation\' VARCHAR(128) NOT NULL);\n""")

sqlTask = "INSERT INTO `users` VALUES\n"

for line in users:
	sqlTask +="("
	values = line.split("|")
	id_val = values[0]
	name = values[1].replace("\'", "\'\'").replace("\"", "\"\"")
	email = values[2]
	gender = values[3]
	date = values[4]
	occupation = values[5][:len(values[5]) - 1]
	sqlTask += id_val + ", \'" + name + "\', \'" + email + "\', \'" + gender + "\', \'" + date + "\', \'" + occupation + "\'" 
	sqlTask += "),\n"

sqlScript.write(sqlTask[: len(sqlTask) - 2] + ";\n")
users.close()


#ratings table


ratings= open('../dataset/ratings.csv')
ratings.readline()

sqlScript.write("""CREATE TABLE `ratings` (
	\'id\' INTEGER PRIMARY KEY AUTOINCREMENT,
	\'user_id\' INTEGER(8) NOT NULL,
	\'movie_id\' INTEGER(8) NOT NULL,
	\'rating\' REAL NOT NULL,
	\'timestamp\' INTEGER(8) NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (movie_id) REFERENCES movies(id));\n""")


sqlTask = "INSERT INTO `ratings` (\'user_id\', \'movie_id\', \'rating\', \'timestamp\') VALUES\n"

for line in ratings:
	values = line.split(",")
	user_id = values[0]
	movie_id = values[1]
	rating = values[2]
	timestamp = values[3][:len(values[3]) - 1]

	sqlTask += "(" + user_id + ", " + movie_id + ", " + rating +", " + timestamp
	sqlTask += "),\n"

sqlScript.write(sqlTask[: len(sqlTask)-2] + ";\n")

ratings.close()


#tags table


tags = open('../dataset/tags.csv')
tags.readline()

sqlScript.write("""CREATE TABLE `tags` (
	\'id\' INTEGER PRIMARY KEY AUTOINCREMENT,
	\'user_id\' INTEGER NOT NULL,
	\'movie_id\' INTEGER NOT NULL,
	\'tag\' VARCHAR(128) NOT NULL,
	\'timestamp\' INTEGER NOT NULL,
	FOREIGN KEY (user_id) REFERENCES users(id),
	FOREIGN KEY (movie_id) REFERENCES movies(id));\n""")

sqlTask = "INSERT INTO `tags` (\'user_id\', \'movie_id\', \'tag\', \'timestamp\') VALUES\n"

for line in tags:
	values = line.split(",")
	user_id = values[0]
	movie_id = values[1]
	tag = values[2].replace("\'", "\'\'").replace("\"", "\"\"")
	timestamp = values[3][:len(values[3]) - 1]
	sqlTask += "(" + user_id + ", " + movie_id + ", \'" + tag + "\', " + timestamp +"),\n"

sqlScript.write(sqlTask[:len(sqlTask)-2]+ ";\n")