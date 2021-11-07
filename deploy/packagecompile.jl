using Pkg
Pkg.instantiate()

using PackageCompiler

create_sysimage(:REPLChat;
    sysimage_path="REPLChat.so",
    precompile_execution_file="deploy/precompile.jl") 