module Client
using HTTP, JSON3, Base64
using ..Model, ..Auth
const SERVER = Ref{String}("https://musicalbums-revd52bpca-uc.a.run.app")
# const SERVER = Ref{String}("http://localhost:8080")

const AUTH_TOKEN = Ref{String}()

# fix this
function sendMessages(user2, body)
    sent = true
    msg = (; user2, sent, body)
    resp = HTTP.put(string(SERVER[], "/messages/$user2"), [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]], JSON3.write(msg); cookies = true)
    return resp
    # return resp.status
end

function createUser(username, password)
    body = (; username, password=base64encode(password))
    resp = HTTP.post(string(SERVER[], "/user"), [], JSON3.write(body); cookies=true)
    if HTTP.hasheader(resp, Auth.JWT_TOKEN_COOKIE_NAME)
        AUTH_TOKEN[] = HTTP.header(resp, Auth.JWT_TOKEN_COOKIE_NAME)
    end
    return "User $username created"
    # return JSON3.read(resp.body, ShowUser)
end

function loginUser(username, password)
    body = (; username, password=base64encode(password))
    resp = HTTP.post(string(SERVER[], "/user/login"), [], JSON3.write(body); cookies=true)
    if HTTP.hasheader(resp, Auth.JWT_TOKEN_COOKIE_NAME)
        AUTH_TOKEN[] = HTTP.header(resp, Auth.JWT_TOKEN_COOKIE_NAME)
    end
    return JSON3.read(resp.body, User)
    # return "Login Successful!"
end

function getMessages(username)
    resp = HTTP.get(string(SERVER[], "/messages/$username"),  [Auth.JWT_TOKEN_COOKIE_NAME => AUTH_TOKEN[]]; cookies = true)
    return JSON3.read(resp.body, Union{ShowMessages, String})
end

end