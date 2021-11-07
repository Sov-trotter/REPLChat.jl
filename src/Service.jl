module Service

using Dates, ExpiringCaches
using ..Model, ..Mapper, ..Auth

function sendMessage(to_user, message)
    @assert haskey(message, :user2) && !isempty(message.user2)
    @assert haskey(message, :sent) && !isempty(message.sent)
    @assert haskey(message, :body) && !isempty(message.body)
    msg = Message(to_user, message.sent, message.body)
    Mapper.send!(msg)
    return "Message Sent!"
end

function getMessages(from_user::String)
    return Mapper.receive(from_user) 
end

function createUser(user)
    @assert haskey(user, :username) && !isempty(user.username)
    @assert haskey(user, :password) && !isempty(user.password)
    user = User(user.username, user.password)
    Mapper.create!(user)
    return user
end

function loginUser(user)
    persistedUser = Mapper.get(user)
    if persistedUser.password == user.password
        persistedUser.password = ""
        return persistedUser
    else
        throw(Auth.Unauthenticated())
    end
end


end




# function createUser(obj)
#     @assert haskey(obj, :name) && !isempty(obj.name)
#     @assert haskey(obj, :username) && !isempty(obj.username)
#     user = User(obj.name, obj.username)
#     Mapper.store!(user)
#     return user
# end
