#=
------------------   開発パッケージ登録   ------------------
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

using LazyJSON, Pipe

iswsl() = haskey(ENV, "WSLENV")

( () -> begin
    #colorscheme!("Monokai16")
    home = iswsl() ? "/mnt/c/Users/oksho" : homedir()
    one = joinpath(home, "OneDrive")
    ytdl = if Sys.iswindows() || iswsl()
        joinpath(home, "Desktop")
    else
        joinpath(home, "デスクトップ")
    end
    kvs = (
        "ONEDRIVE" => one,
        "STARTUP"  => joinpath(one, "asset", "config", "startup.jl"),
        "YTDL_DIR" => ytdl,
        "PYTHON3"  => Sys.which("python3"),
        "PIP3"     => Sys.iswindows() ? Sys.which("pip") : Sys.which("pip3")
    )
    for kv ∈ kvs
        push!(ENV, kv)
    end
    printstyled("●読込成功", color=:light_cyan)
    println(" → startup.jl\n")
end)()




# ------------------------------------------------------------
# -----------------------   Utility   ------------------------
# ------------------------------------------------------------
okdir(dir...; base="github") = joinpath(ENV["ONEDRIVE"], base, dir...)

isalpine() = haskey(ENV, "WSL_DISTRO_NAME") && ENV["WSL_DISTRO_NAME"]=="Alpine"

okmsg(op, msg) = okmsg(:info, op, msg)
function okmsg(type, op, msg)
    t = Symbol(type)
    color, sym = if t ≡ :info
        :light_cyan, "✅"
    elseif t ≡ :warn
        :yellow, "⚠️"
    elseif t ≡ :error
        :light_red, "×"
    else
        :white, ""
    end
    printstyled(sym*op, bold=true, color=color)
    print(" → $msg\n")
end





# ------------------------------------------------------------
# -----------------------   Franklin   -----------------------
# ------------------------------------------------------------
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

function stylus(name="JCS")
    stylus_cmd = if Sys.iswindows()
        `$(joinpath(NodeJS.nodejs_path, "stylus.cmd"))`
    else
        `$(nodejs_cmd()) $(joinpath(NodeJS.nodejs_path, "bin", "stylus"))`
    end
    styl = okdir(name, "_css", "main.styl")
    if isfile(styl)
        run(`$(stylus_cmd) -c $(styl)`)
    else
        printstyled("❌アクセス", bold=true, color=:light_red)
        print(" ➡️ $styl\n")
    end
end





# ------------------------------------------------------------
# ------------------------   Scoop   -------------------------
# ------------------------------------------------------------
function 最新リポjson(bucket="main", dir=homedir())
	path = joinpath(dir, "scoop", "buckets", bucket, "bucket")
	packages = readdir(path) |> sort
	d = Dict{String,Dict{String,Union{Bool, String}}}()
	for p ∈ packages
		name = p |> splitext |> first
		push!(
			d,
			name => Dict{String,Union{String,Bool}}(
                "description" => "",
                "category" => "",
				"need" => true
			)
		)
	end
	dest = joinpath(homedir(), bucket*".json")
	open(dest, "w") do io
		JSON.print(io, d, 4)   # 4 spaces
	end
	return nothing
end

function パッケージ問い合わせ(package, bucket)
    file = okdir(bucket*".json", base="asset")
	text = read(file) |> String
	j = LazyJSON.value(text)
	if package ∉ keys(j)
		printstyled("⚠新規追加 →", color=:red)
	else
		info = j[package]
		if !info["need"]
			return nothing
		elseif isempty(info["description"])
			printstyled("⚠情報登録が必要 →", color=:light_cyan)
		else
			return nothing
		end
    end
    print(" " * package * "\n")
    return nothing
end

function scoop(msg)
	lines = split(msg, '\n', keepempty=false)
	indices = Tuple{Int, String}[]
	for i ∈ eachindex(lines)
		if (startswith(lines[i], "Updating") && endswith(lines[i], "bucket..."))
			bucket_name = split(lines[i], '\'')[2]
			push!(indices, (i, bucket_name))
		end
	end
	for i ∈ eachindex(indices)
		start = first(indices[i]) + 1
		stop = i < lastindex(indices) ? first(indices[i+1])-1 : lastindex(lines)
        bucket = last(indices[i])
        printstyled(bucket * " bucket" * '\n', color=:yellow)
		for j ∈ start:stop
            name = @pipe lines[j] |>
                split(_, ' ', keepempty=false, limit=4) |>
                split(_[3], '@', limit=2) |>
                first |>
                strip(_, [':'])
			パッケージ問い合わせ(name, bucket)
		end
	end
	return nothing
end





# ------------------------------------------------------------
# -----------------------   Extended   -----------------------
# ------------------------------------------------------------
# \lessapprox <tab>
⪅(x::AbstractFloat, y::AbstractFloat) = x<y || x≈y
# \gtrapprox <tab>
⪆(x::AbstractFloat, y::AbstractFloat) = x>y || x≈y
