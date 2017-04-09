if __name__ == '__main__':
    match_file = open("team_avg_2015.csv")
    probability = {}
    for line in match_file:
        data = line.split(",")
        h_rating = int(data[0])
        a_rating = int(data[1])
        if (h_rating,a_rating) not in probability and (a_rating,h_rating) not in probability:
            probability[h_rating, a_rating] = []


    match_file.close()
    match_file = open("team_avg_2015.csv")


    for line in match_file:
        data = line.split(",")
        h_rating = int(data[0])
        a_rating = int(data[1])
        win = int(data[2])
        draw = int(data[3])
        if (a_rating, h_rating) in probability:
            if len(probability[a_rating, h_rating]) == 0:
                probability[a_rating, h_rating].append(0)
                probability[a_rating, h_rating].append(draw)
                probability[a_rating, h_rating].append(win)
            else:
                if win == 1:
                    probability[a_rating, h_rating][2] += 1
                elif draw == 1:
                    probability[a_rating, h_rating][1] += 1
        elif len(probability[h_rating, a_rating]) == 0:
            probability[h_rating, a_rating].append(win)
            probability[h_rating, a_rating].append(draw)
            probability[h_rating, a_rating].append(0)
        else:
            if win == 1:
                probability[h_rating, a_rating][0] += 1
            elif draw == 1:
                probability[h_rating, a_rating][1] += 1


    for match in probability:
        numGames = probability[match][0] + probability[match][1] + probability[match][2]
        probability[match][0] /= numGames
        probability[match][1] /= numGames
        probability[match][2] /= numGames

    file = open('rating' + '.csv', 'w+', newline='')

    file.write("home_rating" + ',' + 'away_rating' + ',' + 'win' + ',' + 'draw,' + 'loss' + '\n')

    for match in probability:
        file.write(str(match[0]) + ',' + str(match[1]) + ',' + str(probability[match][0]) + ',' + str(probability[match][1]) + ',' + str(probability[match][2]) + '\n')


    print(probability)

    match_file.close()
