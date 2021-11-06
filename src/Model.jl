module Model

using StructTypes, Dates
export User, Message, Chat, ShowMessages, ShowUser

mutable struct Message
    id::Int # service managed
    chat_id::Int
    user2::String # username
    sent::Bool # is the message sent or received
    body::String
    timestamp::DateTime # service managed
end

mutable struct ShowMessage
    user2::String # username
    body::String
    timestamp::DateTime
end


mutable struct ShowMessages
    with_user::String # username
    msg_body::String
    timestamp::DateTime
end

==(x::Message, y::Message) = x.id == y.id
Message() = Message(0, 0, "", false, "", Dates.now()) # for struct types - it needs that
Message(user2, sent, body) = Message(0, 0, user2, sent, body, Dates.now())
StructTypes.StructType(::Type{Message}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{Message}) = :id #fk


# ==(x::ShowMessage, y::ShowMessage) = x.id == y.id
ShowMessage() = ShowMessage("", "", Dates.now()) # for struct types - it needs that
ShowMessage(user2, body) = ShowMessage(user2, body, Dates.now())
StructTypes.StructType(::Type{ShowMessage}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{ShowMessage}) = :user2 #fk

ShowMessages() = ShowMessages("", "", Dates.now()) # for struct types - it needs that
ShowMessages(user2, body) = ShowMessages(user2, body, Dates.now())
StructTypes.StructType(::Type{ShowMessages}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{ShowMessages}) = :with_user #fk

mutable struct User
    id::Int64 # service-managed
    username::String # fk with message
    password::String
end

==(x::User, y::User) = x.id == y.id
User() = User(0, "", "")
User(username::String, password::String) = User(0, username, password)
User(id::Int64, username::String) = User(id, username, "")
StructTypes.StructType(::Type{User}) = StructTypes.Mutable()
StructTypes.idproperty(::Type{User}) = :id

mutable struct Chat
    chat_id::Int # service-managed
    with_user::String
end

Chat() = Chat(0, "")
Chat(with_user) = Chat(0, with_user)
end