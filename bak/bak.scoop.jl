using JSON3


json_bytes = read(`pwsh -c "scoop export --config"`)

open(joinpath(homedir(), "scoop.app.json"), "w") do io
    write(io, json_bytes)
end

json = JSON3.read(String(copy(json_bytes)))

out_file = joinpath(homedir(), "scoop.excel.tsv")

open(out_file, "w") do io
    tab_str = map(json[:apps]) do entry
        entry[:Name] * "\t" * entry[:Source]
    end
    for str ∈ tab_str
        write(io, str)
        write(io, "\n")
    end
end