-- The monsters are built by shared code (Hunter/Monsters.luau) so the client can build them too;
-- the live city (Npcs, the Studio plugin's previews) still finds them here.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return require(ReplicatedStorage:WaitForChild("LifeSim"):WaitForChild("Hunter"):WaitForChild("Monsters"))
