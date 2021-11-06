using REPLChat
using Test

@testset "REPLChat.jl" begin
    DBFILE = joinpath(dirname(pathof(REPLChat)), "../test/replchat.sqlite")
    server = @async REPLChat.run(DBFILE)
    Client.createUser("Arsh", "chickentendies")
    user = Client.loginUser("Arsh", "chickentendies")
    using HTTP; HTTP.CookieRequest.default_cookiejar[1]

    resp = Client.sendMessages("foo", "hi from arsh_tests_precompile")    
    Client.getMessages("foo")
end
