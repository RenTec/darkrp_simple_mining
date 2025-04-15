---------------------------------------
----DO NOT TOUCH THESE VARIABLES!!!----
SM = SM or {}
SM.oreData = {}

SM.fileName = "simple_mining_data.json"
-----------| ---------- | --------------
-----------v EDIT BELOW v --------------


-- Rainbow RGB speed!
SM.Speed = 20

-- Rock type payout values
SM.diamondValue = 1000
SM.emeraldValue = 600
SM.goldValue = 150
SM.largeValue = 1500
SM.rainbowValue = 2000
SM.rubyValue = 800
SM.sapphireValue = 400
SM.wallValue = 1500

-- Rock type respawn times in seconds
SM.diamondRespawn = 240 -- 4 minutes
SM.emeraldRespawn = 120 -- 2 minutes
SM.goldRespawn = 60 -- 1 minute
SM.largeRespawn = 360 -- 6 minutes
SM.rainbowRespawn = 300 -- 5 Minutes
SM.rubyRespawn = 180 -- 3 minutes
SM.sapphireRespawn = 120 -- 2 minutes
SM.wallRespawn = 360 -- 6 minutes

-- Rock type health values
SM.diamondHealth = 400
SM.emeraldHealth = 200
SM.goldHealth = 100
SM.largeHealth = 800
SM.rainbowHealth = 500
SM.rubyHealth = 300
SM.sapphireHealth = 200
SM.wallHealth = 800

-- Use model radius in addition to the rock type base value? ?
SM.useRadius = true

-- Multiplier if useRadius is false
SM.rockMultiplier = 2

--[[
     !!! DO NOT TOUCH ANYTHING BELOW THIS OR THINGS WILL BREAK !!!

     !!! DO NOT TOUCH ANYTHING BELOW THIS OR THINGS WILL BREAK !!!

     !!! DO NOT TOUCH ANYTHING BELOW THIS OR THINGS WILL BREAK !!!
--]]

-- Small rock models
SM.rockModels = 
{
    "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_c.mdl",
    "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_a.mdl",
    "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_wall_damaged_small.mdl",
    "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_b.mdl",
    "models/props_abandoned/crystals_fixed/crystal_stump/crystal_small_stump_a.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_wall_small_b.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_wall_small_a.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_small_c.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_small_b.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_small_a.mdl",
    "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_wall_damaged_small.mdl",
    "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_small_damaged_b.mdl",
    "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_small_damaged_a.mdl"
}

-- Large rock models
SM.largeRocks =
{
   "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_huge_damaged_a.mdl",
   "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_huge_damaged_b.mdl",
   "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_huge_a.mdl",
   "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_huge_b.mdl",
   "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_huge_d.mdl",
   "models/props_abandoned/crystals_fixed/crystal_stump/crystal_huge_stump_a.mdl",
   "models/props_abandoned/crystals_fixed/crystal_stump/crystal_huge_stump_b.mdl",
   "models/props_abandoned/crystals_fixed/crystal_stump/crystal_huge_stump_c.mdl"
}

-- Large wall rocks
SM.wallRocks =
{
    "models/props_abandoned/crystals_fixed/crystal_damaged/crystal_cluster_wall_damaged_huge.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_wall_huge_a.mdl",
    "models/props_abandoned/crystals_fixed/crystal_default/crystal_cluster_wall_huge_b.mdl",
    "models/props_abandoned/crystals_fixed/crystal_stump/crystal_huge_stump_wall_a.mdl",
    "models/props_abandoned/crystals_fixed/crystal_stump/crystal_huge_stump_wall_b.mdl" 
}

function SM.Rainbow()
    color = HSVToColor(CurTime() * SM.Speed % 360, 1, 1)
    return Color(color.r, color.g, color.b, 255)
end

if SERVER then
    function SM.Notify(ply, amount)
        DarkRP.notify(ply, 0, 4, "Mined $" .. tostring(amount) )
    end

    function SM.Payout(ply, base, args)
        local payment = base + args
        ply:addMoney(payment)
        SM.Notify(ply, payment)
    end
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
                    rock:SetRenderMode( RENDERMODE_NORMAL ) -- I dont think this does anything
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