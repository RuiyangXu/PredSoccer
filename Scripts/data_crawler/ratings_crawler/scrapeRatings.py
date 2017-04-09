from lxml import html
import requests
import codecs

def main():
    
    '''
    Scrape Rating Data for Every Player by Year & Output to CSV
    '''

    getData()
    
def getData():
    ratings10 = getPlayerDataFromYear("10")
    outputPlayerRatingTableData(ratings10, "10")


'''
outputPlayerRatingTableData
Input: the dictionary of player ratings for the year, and the year
Output: write data to player-ratings-[year].csv
Called by: main
'''
def outputPlayerRatingTableData(playerData, year):
    #year, name, position, rating, pac, sho, pas, dri, def, phy
    print("outputting player ratings for " + str(year))
    outFile = "player-ratings-" + year + ".csv"
    output = codecs.open(outFile, 'a')
    try:
        for player in playerData:
            p= playerData[player]
            #print(playerData)
            output.write(str(p['year']) + "," + p['name'] + "," + str(p['position']) + "," + str(p['rating'])
            + "," + str(p['pac']) + "," + str(p['sho']) + "," + str(p['pas'])
            + "," + str(p['dri']) + "," + str(p['def']) + "," + str(p['phy']) + "\n")
    except Exception as exc:
        print('Generated an exception for ' + str(player) + ' during output: ' + str(exc))

        
    output.close()


'''
getPlayerDataFromYear
Input: a year (10-16) to grab player data from the futhead website
Output: dictionary of player data dictionaries, with key being the name of the player
Called by: main
'''
def getPlayerDataFromYear(year):
    allPlayers = {}
    playerListURL = "http://www.futhead.com/" + year + "/players/"
    playerLinks = iteratePages(playerListURL)
    print("Number of Players for 20" + year + " : " + str(len(playerLinks)))
    for link in playerLinks:
        try:
             playerData = parsePlayerPage(link,year)
             name = playerData['name']
             rating = playerData['rating']
             if name not in allPlayers:
                allPlayers[name] = playerData
        except KeyError as k:
            print('Key error with ' + str(link))

    return allPlayers

'''
parsePlayerPage
Input: a link to a player page
Output: a dictionary of key-value pairs of ranking data 
Called by: getPlayerDataFromYear 

Values Collected:
Name,Year,Country,Position,Rating,PAC,SHO,PAS,DRI,DEF,PHY
'''
def parsePlayerPage(link,year):
    playerData = {}
    
    #the year is passed in just the extention (10,11,etc.)
    playerData['year'] = "20" + year
    
    page = requests.get(link)
    tree = html.fromstring(page.content.decode('UTF-8'))
                   
    try:
            name =  tree.xpath("/html/body/div[3]/div/div/div/div/div[3]/span")
            playerData['name'] = name[0].text
            position = tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[4]")
            playerData['position'] = str(position[0].text)
            rating = tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[2]")
            playerData['rating'] = str(rating[0].text)
            pac = str(tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[8]")[0].text)
            sho = str(tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[9]")[0].text)
            pas = str(tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[10]")[0].text)
            dri = str(tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[11]")[0].text)
            theDEF = str(tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[12]")[0].text)
            phy = str(tree.xpath("/html/body/div[5]/div[1]/div[1]/ul/li/div[1]/div[1]/div[1]/div[13]")[0].text) 
                
            playerData['pac'] = pac
            playerData['sho'] = sho
            playerData['pas'] = pas
            playerData['dri'] = dri
            playerData['def'] = theDEF
            playerData['phy'] = phy
 
            
    except IndexError as e:
        print("Index error at " + link + " " + str(e) + "\n")
    print(str(playerData)) 
    return playerData
    
    

'''
iteratePages
Input: the base URL for the player list page of a specified year
Output: A list of all the individual player links for the year
Called by: getPlayerDataFromYear
'''
def iteratePages(playerListURL):

    allPlayerLinks = []
    pageNum = 1 #starting page number
    #print("Getting Players from Page 1")
    paginatedURL = playerListURL + "?page=" + str(pageNum)
    page = requests.get(paginatedURL)
    tree = html.fromstring(page.content)
    playerLinks = getPlayerLinks(tree)
    for link in playerLinks:
        if link not in allPlayerLinks: #make sure there aren;t any duplicate entries
            allPlayerLinks.append(link)
    
    newPage = getNextPage(tree)
    while(newPage != ""):
        #print("Getting Players from " + str(newPage))
        newPaginatedURL = playerListURL + str(newPage)
        nextPage = requests.get(newPaginatedURL)
        newTree = html.fromstring(nextPage.content)
        playerLinks = getPlayerLinks(newTree)
        for link in playerLinks:
            if link not in allPlayerLinks:
                allPlayerLinks.append(link)
        newPage = getNextPage(newTree)
    print("Retrieved All Player Links")
    return allPlayerLinks


'''
getPlayerLinks
Input: the URL for a page of the list of players for a year, with page number specified
Output: returns a list of links to the player's pages
Called by: iteratePages
'''
def getPlayerLinks(tree):
    baseURL = "http://www.futhead.com"
    playerLinks = []
    playerList = tree.xpath("/html/body/div[5]/div/div[1]/ul/li") 
    numPlayers = len(playerList)
    for i in range(numPlayers):
        playerPath = tree.xpath("/html/body/div[5]/div/div[1]/ul/li[" + str(i) + "]/div/a")
        if len(playerPath) != 0:
            playerLink = baseURL + playerPath[0].get('href')
            playerLinks.append(playerLink)
    return playerLinks

    
'''
getNextPage
Input: tree (ElementTree of html page)
Output: url path (format \?page=<PAGENUM> ) If on the last page, returns ""
Called by: iteratePages
'''
def getNextPage(tree):
    nextURL = ""
    nextPageButton = tree.xpath("/html/body/div[3]/div/div/div[2]/a[3]")
    for button in nextPageButton:
        nextButtonClass = button.get('class')
        if(nextButtonClass != 'tooltip-enabled cursor-not-allowed opacity-15'):
            nextURL = button.get('href')
    return nextURL

main()
