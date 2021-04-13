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
extension(file; dot=true) = file[findlast('.', file)+Int(!dot) : end]
okdir(dir...; root="github") = joinpath(ENV["ONEDRIVE"], root, dir...)
okdotfiles(path...) = okdir("dotfiles", path...; root="asset")

# TOML database
function readtoml(name)
    file = joinpath(okdir("database"; root="asset"), name)
    isfile(file) || return error("TOML file $name isn't exist.")
    TOML.parsefile(file)
end

# system utils
iswsl() = haskey(ENV, "WSLENV")
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
        @eval using OhMyREPL
    catch e
        @warn "OhMyREPL インポートエラー" e
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