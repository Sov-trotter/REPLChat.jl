using Revise, REPLChat

const DBFILE = joinpath(dirname(pathof(REPLChat)), "../test/repl_chat.sqlite")
const AUTHFILE = "file://" * joinpath(dirname(pathof(REPLChat)), "../resources/authkeys.json")

server = @async REPLChat.run(DBFILE, AUTHFILE)

Client.createUser("Arsh", "chickentendies")
user = Client.loginUser("Arsh", "chickentendies")

using HTTP; HTTP.CookieRequest.default_cookiejar[1]

resp = Client.sendMessages("foo", "hi from arsh")




# alb1 = Client.createAlbum("Free Yourself Up", "Lake Street Dive", 2018, ["Baby Don't Leave Me Alone With My Thoughts", "Good Kisser"])
# @test Client.pickAlbumToListen() == alb1
# @test Client.pickAlbumToListen() == alb1

# @test Client.getAlbum(alb1.id) == alb1

# push!(alb1.songs, "Shame, Shame, Shame")
# alb2 = Client.updateAlbum(alb1)
# @test length(alb2.songs) == 3
# @test length(Client.getAlbum(alb1.id).songs) == 3

# Client.deleteAlbum(alb1.id)
# # Client.pickAlbumToListen()

# alb2 = Client.createAlbum("Haunted Heart", "Charlie Haden Quartet West", 1991, ["Introduction", "Hello My Lovely"])
# @test Client.pickAlbumToListen() == alb2