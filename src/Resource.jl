module Resource

using Dates, HTTP, JSON3 # allows reading custom structs
using ..Model, ..Service, ..Auth, ..Contexts, ..Workers # .. go outside this module to the parent of Resource and look for model in that scope :)

const ROUTER = HTTP.Router()

# send message to a user
# /message/* means message/username and is captured by the wildcard
sendMessage(req) = fetch(Workers.@async(Service.sendMessage(HTTP.URIs.splitpath(req.target)[2], JSON3.read(req.body))))
HTTP.@register(ROUTER, "PUT", "/messages/*", sendMessage)

# get latest message from a user
getMessages(req) = Service.getMessages(HTTP.URIs.splitpath(req.target)[2])
HTTP.@register(ROUTER, "GET", "/messages/*", getMessages)

function contextHandler(req)
    withcontext(User(req)) do
        HTTP.Response(200, JSON3.write(HTTP.handle(ROUTER, req)))
    end
end

const AUTH_ROUTER = HTTP.Router(contextHandler)

function authenticate(user::User)
    resp = HTTP.Response(200, JSON3.write(user))
    return Auth.addtoken!(resp, user)
end

createUser(req) = fetch(Workers.@async(authenticate(Service.createUser(JSON3.read(req.body))::User)))
HTTP.@register(AUTH_ROUTER, "POST", "/user", createUser)

loginUser(req) = authenticate(Service.loginUser(JSON3.read(req.body, User))::User)
HTTP.@register(AUTH_ROUTER, "POST", "/user/login", loginUser)

function requestHandler(req)
    # start = Dates.now(Dates.UTC)
    # @info (timestamp=start, event="ServiceRequestBegin", tid=Threads.threadid(), method=req.method, target=req.target)
    local resp
    try
        resp = HTTP.handle(AUTH_ROUTER, req)
        # resp = HTTP.Response(JSON3.write(HTTP.handle(ROUTER, req)))

    catch e
        if e isa Auth.Unauthenticated
            resp = HTTP.Response(401)
        else
            s = IOBuffer()
            showerror(s, e, catch_backtrace(); backtrace=true)
            errormsg = String(resize!(s.data, s.size))
            @error errormsg
            resp = HTTP.Response(500, errormsg)
        end
    end
    # stop = Dates.now(Dates.UTC)
    # @info (timestamp=stop, event="ServiceRequestEnd", tid=Threads.threadid(), method=req.method, target=req.target, duration=Dates.value(stop - start), status=resp.status, bodysize=length(resp.body))
    return resp
end

function run()
    HTTP.serve(requestHandler, "0.0.0.0", 8080)
end

end