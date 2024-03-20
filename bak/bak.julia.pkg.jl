using Pkg, JSON3


deps = Dict{String,String}()

for (k, v) in Pkg.project().dependencies
    deps[k] = string(v)
end

open(joinpath(homedir(), "julia.pkg.json"), "w") do io
    JSON3.pretty(io, deps)
end
