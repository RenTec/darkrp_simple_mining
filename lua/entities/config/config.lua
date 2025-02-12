SM = SM or {}
SM.oreData = {}

SM.fileName = "simple_mining_data.json"
SM.respawnTime = 60

SM.rockModels = 
{
    [2000] = "models/props/cs_militia/rocksteppingstones01.mdl",
	[500] = "models/perftest/rocksground01a.mdl",
	[100] = "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_c.mdl",
	[750] = "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_a.mdl",
	[250] = "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_wall_damaged_small.mdl"
}

concommand.Add( "sm_save", function( ply, cmd, args )
    if not file.IsDir("sm_dat", "DATA") then
        file.CreateDir("sm_dat")
    end

    local rocks = ents.FindByClass("*_rocks")
    local savedCount = 0
    for _, rock in ipairs(rocks) do
        local posData = {
            position = rock:GetPos(),
            angles = rock:GetAngles(),
            ore = rock:GetModel(),
            class = rock:GetClass(),
            col = rock:GetColor(),
            mat = rock:GetMaterial()
        }
        savedCount = savedCount + 1
        table.insert(SM.oreData, posData)
    end
    local jsonPosData = util.TableToJSON(SM.oreData, true)
    file.Write("sm_dat/" .. SM.fileName, jsonPosData)
    print("Saved " .. savedCount .. " mining locations.")
end )

local function SpawnRocks()
    if file.Exists("sm_dat/" .. SM.fileName, "DATA") then
        local jsonPosData = file.Read("sm_dat/" .. SM.fileName, "DATA")
        local posData = util.JSONToTable(jsonPosData)
        local rocks = ents.FindByClass("*_rocks")
        local loadCount = 0

        for _, rock in ipairs(rocks) do
            rock:Remove()
            loadCount = loadCount + 1
        end
        print("Removed " .. loadCount .. " rocks!")
        if posData then
            for k, v in pairs(posData) do
                local rock = ents.Create(v.class)
                if IsValid(rock) then
                    rock:SetModel( v.ore )
                    rock:SetPos( v.position )
                    rock:SetAngles( v.angles )
                    rock:SetColor( v.col )
                    rock:SetMaterial( v.mat )
                    rock:Spawn()
                    rock:Activate()
                    rock:SetRenderMode( RENDERMODE_GLOW ) -- I dont think this does anything
                    rock:SetCollisionGroup( 20 )
                    rock.shouldRespawn = true
                    rock:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
                    rock:SetNWBool( "lightOn", true )
                end
            end
        end
    end
end

hook.Add("PostCleanupMap", "RockLoader", function()
    SpawnRocks()
end )

hook.Add( "InitPostEntity", "some_unique_name", function()
    SpawnRocks()
end )

concommand.Add( "sm_load", function( ply, cmd, args )
    SpawnRocks()
end )