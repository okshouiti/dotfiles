#=
------------------   事前コンパイル   ------------------
julia> using PackageCompiler
julia> pkgs = [
            :HTTP,
            :LazyJSON,
            :Pipe
       ]
julia> PackageCompiler.create_sysimage(pkgs, sysimage_path="sysimage.so")

------------------   開発パッケージ登録   ------------------
julia> cd(okdir("YTDL"))
(@v1.5) pkg> dev .
=#



# ------------------------------------------------------------
# -----------------------   Utility   ------------------------
# ------------------------------------------------------------

# filesystem utils
#extension(file; dot=true) = isfile(file) ? file[findlast('.', file)+Int(!dot) : end] : ""
extension(file; dot=true) = isfile(file) ? last(rsplit(file, '.', limit=2)) : ""
okdir(dir...; root="github") = joinpath(ENV["ONEDRIVE"], root, dir...)
okdotfiles(path...) = okdir("dotfiles", path...; root="asset")

# TOML database
# kdb(filename::AbstractString) = okdb(:READ, filename)
macro okdb_str(cmds)
    sub_cmds = split(cmds, ' ', limit=2) |> last
    dir = okdir("database"; root="asset")
    if startswith(cmds, "show ")
        filter(readdir(dir)) do item
            println(item)
            isfile(item) && extension(item, dot=false) == sub_cmds
        end .|> println
        return nothing
    elseif startswith(cmds, "read ")
        _okdb_read(joinpath(dir, sub_cmds))
    elseif startswith(cmds, "search ")
        filename, key = rsplit(sub_cmds, ' ', limit=2)
        _okdb_search(joinpath(dir, filename), key)
    else
        error("Invalid commands!")
    end
end

_okdb_read(file) = TOML.parsefile(file)
_okdb_search(file, key) = filter(_okdb_read(file)) do (dbkey, v)
    occursin(key, dbkey)
end
#_okdb_search(file, key) = filter( pair->occursin(key, pair.first), _okdb_read(file) )
#=function _okdb_search(file, key)
    filter(_okdb_read(file)) do (k, v)
        occursin(string(key), k)
    end
end=#

#_okdb_search(file, key) = filter( (k,v)->occursin(string(key), k), _okdb_read(file) )


# system utils
iswsl() = get(ENV, "WSL_DISTRO_NAME", "") != ""
isalpine() = get(ENV, "WSL_DISTRO_NAME", "") == "Alpine"

# math utils
⪅(x::AbstractFloat, y::AbstractFloat) = x<y || x≈y # \lessapprox <tab>
⪆(x::AbstractFloat, y::AbstractFloat) = x>y || x≈y # \gtrapprox <tab>

# Franklin utils
function okserve(name="JCS"; kwargs...)
    dir = okdir(name)
    if isdir(dir)
        cd(dir) do
            serve(; kwargs...)
        end
    else
        printstyled("❌アクセス", bold=true, color=:light_red)
        print(" ➡️ $dir\n")
    end
end



# ------------------------------------------------------------
# -------------------   REPL Initiation   --------------------
# ------------------------------------------------------------
atreplinit() do repl
    # import packages
    try
        @eval using OhMyREPL, TOML
    catch e
        @warn "インポートエラー" e
    end

    # add EnvDict
    home = iswsl() ? "/mnt/c/Users/oksho" : homedir()
    foreach(p -> push!(ENV, p), (
        "ONEDRIVE" => joinpath(home, "OneDrive"),
        "STARTUP"  => joinpath(okdotfiles("startup.jl")),
        "YTDL_DIR" => joinpath(home, "Desktop"),
        "PYTHON3"  => Sys.which("python3"),
        "PIP3"     => @static Sys.iswindows() ? Sys.which("pip") : Sys.which("pip3")
    ))

    printstyled("●読込成功", color=:light_cyan)
    println(" → startup.jl\n")
end