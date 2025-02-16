SM = SM or {}
SM.oreData = {}

SM.fileName = "simple_mining_data.json"
SM.respawnTime = 120
SM.Speed = 20

SM.rockModels = 
{
	[100] = "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_c.mdl",
	[750] = "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_a.mdl",
	[250] = "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_wall_damaged_small.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_b.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_a.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_wall_small_b.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_wall_small_a.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_small_c.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_small_b.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_small_a.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_wall_damaged_small.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_small_damaged_b.mdl",
    [150] = "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_small_damaged_a.mdl"
}


function SM.Rainbow()
    color = HSVToColor(CurTime() * SM.Speed % 360, 1, 1)
    return Color(color.r, color.g, color.b, 255)
end

concommand.Add( "sm_save", function( ply, cmd, args )
    if ply:IsSuperAdmin() then
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
                col = rock:GetColor()
            }
            savedCount = savedCount + 1
            table.insert(SM.oreData, posData)
        end
        local jsonPosData = util.TableToJSON(SM.oreData, true)
        file.Write("sm_dat/" .. SM.fileName, jsonPosData)
        print("Saved " .. savedCount .. " mining locations.")
    else
        print("YOU HAVE NO POWER HERE, MWUAHAHAHA")
    end
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
                    rock:Spawn()
                    rock:Activate()
                    rock:SetRenderMode( RENDERMODE_GLOW ) -- I dont think this does anything
                    rock:SetCollisionGroup( 20 )
                    rock.shouldRespawn = true
                    rock:AddEFlags( EFL_FORCE_CHECK_TRANSMIT )
                end
            end
        end
    end
end

local function DeleteRocks()
    if file.Exists("sm_dat/" .. SM.fileName, "DATA") then
        file.Delete("sm_dat/" .. SM.fileName)
    end

    local rocks = ents.FindByClass("*_rocks")
    local deleteCount = 0

    for _, rock in ipairs(rocks) do
        rock:Remove()
        deleteCount = deleteCount + 1
    end
    print("Removed " .. deleteCount .. " rocks!")
end

hook.Add("PostCleanupMap", "RockLoader", function()
    SpawnRocks()
end )

hook.Add( "InitPostEntity", "some_unique_name", function()
    SpawnRocks()
end )

concommand.Add( "sm_load", function( ply, cmd, args )
    if ply:IsSuperAdmin() then
        SpawnRocks()
    else
        print("YOU HAVE NO POWER HERE, MWUAHAHAHA")
    end
end )

concommand.Add( "sm_delete_all", function( ply, cmd, args )
    if ply:IsSuperAdmin() then
        DeleteRocks()
    else
        print("YOU HAVE NO POWER HERE, MWUAHAHAHA")
    end
end )

hook.Add("SetupPlayerVisibility","PVSChecks",function(ply)
    for _,ent in pairs(ents.FindByClass("*_rocks")) do
        if IsValid(ent) and ply:TestPVS(ent) and ent.shouldRespawn then
            ent:SetNWBool( "lightOn", true )
        elseif IsValid(ent) then
            ent:SetNWBool( "lightOn", false)
        end
    end
end)