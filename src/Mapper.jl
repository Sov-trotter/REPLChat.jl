module Mapper

using SQLite, DBInterface, Strapping, Tables
using ..Model, ..Contexts, ..ConnectionPools

const DB_POOL = Ref{ConnectionPools.Pod{ConnectionPools.Connection{SQLite.DB}}}()
const COUNTER = Ref{Int64}(0)

# creates a pool of connections to the databse for simultaneous requests
function init(dbfile)
    new = () -> SQLite.DB(dbfile)
    DB_POOL[] = ConnectionPools.Pod(SQLite.DB, Threads.nthreads(), 60, 1000, new)
    if !isfile(dbfile)
        db = SQLite.DB(dbfile)
        DBInterface.execute(db, """
            CREATE TABLE users (
                id INTEGER PRIMARY KEY,
                username TEXT,
                password TEXT
            )
        """)

        DBInterface.execute(db, """
            CREATE INDEX idx_user_id ON users (id)
        """)
    end
    return
end

# withconnection does thread safe acquire-release stuff
function execute(sql; params = nothing, executemany::Bool=false)
    withconnection(DB_POOL[]) do db
        if !(params isa Nothing) 
            stmt = DBInterface.prepare(db, sql)
            if executemany
                DBInterface.executemany(stmt, params)
            else
                DBInterface.execute(stmt, params)
            end
        else
            DBInterface.execute(db, sql)
        end
    end
end

function receive(from_user)
    user = Contexts.getuser()
    res = execute("SELECT with_user, msg_body, timestamp FROM messages_from_$(from_user)_to_$(user.username) ORDER BY id DESC LIMIT 1")
    Strapping.construct(ShowMessages, res)
end

function send!(msg)    
    user = Contexts.getuser()
    execute("""
        INSERT INTO chats_$(user.username) (with_user) VALUES (?)
    """; params = (with_user = [msg.user2]), executemany = true)
    execute("""
    CREATE TABLE IF NOT EXISTS messages_from_$(user.username)_to_$(msg.user2) (
        id INTEGER PRIMARY KEY,
        with_user TEXT,
        msg_body TEXT,
        timestamp TEXT
        )
    """)
    execute("""
        CREATE INDEX IF NOT EXISTS idx_message_id ON messages_from_$(user.username)_to_$(msg.user2) (id)
    """)
    
    execute("""INSERT INTO messages_from_$(user.username)_to_$(msg.user2) (with_user, msg_body, timestamp) VALUES(?, ?, ?)""";
    params = (with_user = [msg.user2], msg_body = [msg.body], timestamp = [msg.timestamp]), executemany = true)
    return
end


function create!(user::User)
    user.id = COUNTER[] += 1
    execute("""
        INSERT INTO users (id, username, password) VALUES (?, ?, ?)
    """; params = columntable(Strapping.deconstruct(user)), executemany = true)
    
    execute("""
    CREATE TABLE chats_$(user.username) (
        id INTEGER PRIMARY KEY,
        with_user INTEGER
        )
    """)

    execute("CREATE INDEX idx_chats_$(user.username)_id ON chats_$(user.username) (id)")
    return
end

function get(user::User)
    return Strapping.construct(User, execute("SELECT * FROM users WHERE username = ?"; params = (user.username,)))
end

end # module


# function create!(user::User)
#     x = DBInterface.execute(DBInterface.@prepare(getdb, """
#         INSERT INTO users (username, password) VALUES (?, ?)
#     """), (user.username, user.password))
    
#     user.id = DBInterface.lastrowid(x)
#     return "created"
# end
        # DBInterface.execute(getdb(), """
        #     CREATE INDEX idx_user_id ON users (id)
        # """)
        # DBInterface.execute(getdb(), """
        #     CREATE TABLE message (
        #         id INTEGER,
        #         user2 TEXT,
        #         sent INTEGER,
        #         body TEXT,
        #         timestamp TEXT
        #     )
        # """)
        # DBInterface.execute(getdb(), """
        #     CREATE INDEX idx_message_id ON message (id)
        # """)


         # DBInterface.execute(getdb(), """
        #     CREATE INDEX idx_user_id ON users (id)
        # """)
        # DBInterface.execute(getdb(), """
        #     CREATE TABLE message (
        #         id INTEGER,
        #         user2 TEXT,
        #         sent INTEGER,
        #         body TEXT,
        #         timestamp TEXT
        #     )
        # """)
        # DBInterface.execute(getdb(), """
        #     CREATE INDEX idx_message_id ON message (id)
        # """)

        # DBInterface.execute(getdb(), """
        #     CREATE TABLE user_chats (
        #         id INTEGER PRIMARY KEY
        #         user_id INTEGER,            )
        # """)

        # DBInterface.execute(getdb(), """
        #     CREATE TABLE message (
        #         id INTEGER,
        #         chat_id INTEGER
        #         user2 TEXT,
        #         sent INTEGER,
        #         body TEXT,
        #         timestamp TEXT
        #     )
        # """)
        # DBInterface.execute(getdb(), """
        #     CREATE INDEX idx_message_id ON message (user2)
        # """)

# function execute(sql, params; executemany::Bool=false)
#     withconnection(DB_POOL[]) do db
#         stmt = DBInterface.prepare(db, sql)
#         if executemany
#             DBInterface.executemany(stmt, params)
#         else
#             DBInterface.execute(stmt, params)
#         end
#     end
# end
