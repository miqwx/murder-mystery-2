-- FPS BOOST + AIM ASSIST + ESP POR TEAM (MM2-LIKE)
local P=game:GetService("Players")
local R=game:GetService("RunService")
local W=workspace
local LP=P.LocalPlayer
local C=W.CurrentCamera
local L=game:GetService("Lighting")
local Teams=game:GetService("Teams")

-- ===== GRÁFICOS LEVES =====
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
L.GlobalShadows=false
L.FogEnd=1e9
L.Brightness=0
L.EnvironmentDiffuseScale=0
L.EnvironmentSpecularScale=0
L.OutdoorAmbient=Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do
    if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
end

-- ===== REMOVE DECORAÇÕES =====
local nomesDeco={"tree","arvore","plant","bush","folha","leaf","palm","rock","pedra","decor","prop"}
local function isDeco(o)
    for _,n in ipairs(nomesDeco) do
        if o.Name:lower():find(n) then return true end
    end
end
local function opt(o)
    if LP.Character and o:IsDescendantOf(LP.Character) then return end
    if o:IsA("BasePart") then
        o.Material=Enum.Material.Plastic
        o.Reflectance=0
        o.CastShadow=false
        if isDeco(o) then o:Destroy() end
    elseif o:IsA("Decal") or o:IsA("Texture")
    or o:IsA("ParticleEmitter") or o:IsA("Trail")
    or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
        o:Destroy()
    elseif (o:IsA("Model") or o:IsA("Folder")) and isDeco(o) then
        o:Destroy()
    end
end
for _,v in ipairs(W:GetDescendants()) do opt(v) end
W.DescendantAdded:Connect(function(v) task.wait();opt(v) end)

-- ===== FPS COUNTER =====
local gui=Instance.new("ScreenGui",LP.PlayerGui)
gui.ResetOnSpawn=false
local lbl=Instance.new("TextLabel",gui)
lbl.Size=UDim2.fromScale(0.1,0.05)
lbl.Position=UDim2.new(0,10,0,10)
lbl.BackgroundTransparency=1
lbl.TextColor3=Color3.fromRGB(0,255,0)
lbl.Font=Enum.Font.SourceSansBold
lbl.TextSize=18
local fc,lt=0,tick()
R.RenderStepped:Connect(function()
    fc+=1
    if tick()-lt>=1 then lbl.Text="FPS: "..fc;fc=0;lt=tick() end
end)

-- ===== AIM ASSIST (INALTERADO) =====
local FOV=10
local assist=0.1
R.RenderStepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local closest=FOV
    local target
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("Head") then
            local pos,on=C:WorldToViewportPoint(p.Character.Head.Position)
            if on then
                local center=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)
                local dist=(Vector2.new(pos.X,pos.Y)-center).Magnitude
                if dist<closest then closest=dist;target=p.Character.Head.Position end
            end
        end
    end
    if target then
        local dir=(target-C.CFrame.Position).Unit
        C.CFrame=CFrame.new(C.CFrame.Position,C.CFrame.Position+dir:Lerp(dir,assist))
    end
end)

-- ===== ESP POR TEAM (SEM LOBBY) =====
local function clearESP(obj)
    if obj:FindFirstChild("RoleESP") then obj.RoleESP:Destroy() end
end

local function makeESP(obj,color,name)
    clearESP(obj)
    local h=Instance.new("Highlight")
    h.Name=name or "RoleESP"
    h.Adornee=obj
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency=1
    h.OutlineTransparency=0
    h.OutlineColor=color
    h.Parent=obj
end

local function updatePlayerESP(player)
    if player==LP or not player.Character then return end
    local char=player.Character
    clearESP(char)

    if not player.Team then return end
    local t=player.Team.Name:lower()
    if t:find("lobby") then return end

    if t:find("murder") then
        makeESP(char,Color3.fromRGB(255,0,0))        -- 🔴 Assassino
    elseif t:find("sheriff") then
        makeESP(char,Color3.fromRGB(0,120,255))      -- 🔵 Xerife
    elseif t:find("innocent") then
        makeESP(char,Color3.fromRGB(0,255,0))        -- 🟢 Inocente
    end
end

for _,p in ipairs(P:GetPlayers()) do
    if p.Character then updatePlayerESP(p) end
    p.CharacterAdded:Connect(function()
        task.wait(0.2)
        updatePlayerESP(p)
    end)
    p:GetPropertyChangedSignal("Team"):Connect(function()
        task.wait()
        updatePlayerESP(p)
    end)
end

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.2)
        updatePlayerESP(p)
    end)
end)

-- ===== ESP ARMA NO CHÃO =====
local function groundGunESP(obj)
    if obj:FindFirstChild("GunESP") then return end
    local n=obj.Name:lower()
    if n:find("gun") or n:find("revolver") then
        makeESP(obj,Color3.fromRGB(0,200,255),"GunESP")
    end
end

W.DescendantAdded:Connect(function(obj)
    task.wait()
    if obj:IsA("Tool") or obj:IsA("Model") then
        groundGunESP(obj)
    end
end)
