# REPLChat

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Sov-trotter.github.io/REPLChat.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Sov-trotter.github.io/REPLChat.jl/dev)
[![Build Status](https://github.com/Sov-trotter/REPLChat.jl/workflows/CI/badge.svg)](https://github.com/Sov-trotter/REPLChat.jl/actions)

Chat with your friends/colleagues from the <a href="https://julialang.org">
        <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em">
        Julia Language
    </a> REPL itself!


```
using REPLChat

# creates a user
Client.createUser("<your_user_name>", "<password>")

# logs you in
Client.loginUser("<your_name>", "<password>")

# send message to a user
Client.sendMessages("<to_user>", "<message body>")

# fetch the latest message from a user(send to the logged in user)
Client.getMessage("<from_user>")
```
