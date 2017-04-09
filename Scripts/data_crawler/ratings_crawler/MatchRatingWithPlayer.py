def formRatings(fileName, players):
    file = open(fileName)
    players_rating = {}
    for line in file:
        info = line.split(",")
        names = info[1].split( )
        firstName = ''
        lastName = ''
        if len(names) == 1:
            # just one name, like neymar
            lastName = names[0]
        elif len(names) == 2:
            firstName = names[0]
            lastName = names[1]
        elif len(names) == 3:
            firstName = names[0]
            lastName = names[2]
        name = firstName + " " + lastName
        players_rating[name] = line + " " + str(players[name])
        print(name, players_rating[name])
    return players_rating

def formPlayers(fileName):
    file = open(fileName)
    players = {}
    for line in file:
        player = line.split(',')
        player[1] = player[1][0 : len(player[1]) - 1]
        if player[1] == "":
            name = player[2]
        else:
            name = player[1] + " " + player[2]
        players[name] = int(player[0])
    return players


def main():
    players = formPlayers("players.csv")
    formRatings("player-ratings-15.csv",players)

if __name__ == '__main__':
    main()