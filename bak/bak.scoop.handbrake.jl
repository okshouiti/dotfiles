dir_bak_dest = joinpath(homedir(), "OneDrive", "asset", "bak")
dir_appbase = joinpath(homedir(), "scoop", "apps")




# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#                            Handbrake
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function bak_handbrake(filename::AbstractString)
    dir_hb = joinpath(dir_appbase, "handbrake", "current", "storage")
    cp(
        joinpath(dir_hb, filename)
        , joinpath(dir_bak_dest, "scoop.handbrake."*filename)
    )
end

bak_handbrake("presets.json")
bak_handbrake("settings.json")



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#                             MPC-BE
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function bak_mpcbe(filename::AbstractString = "mpc-be64.ini")
    cp(
        joinpath(dir_appbase, "mpc-be", "current", filename)
        , joinpath(dir_bak_dest, "scoop.mpcbe."*filename)
    )
end

bak_mpcbe()



# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#                             ShareX
# @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function bak_sharex(filename::AbstractString)
    cp(
        joinpath(dir_appbase, "sharex", "current", "ShareX", filename)
        , joinpath(dir_bak_dest, "scoop.sharex."*filename)
    )
end

bak_sharex("ApplicationConfig.json")
bak_sharex("HotkeysConfig.json")
