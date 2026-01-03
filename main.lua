-- FPS BOOST + AIM ASSIST COMPACTO + ESP XERIFE/ASSASSINO
local P=game:GetService("Players");local R=game:GetService("RunService");local W=workspace;local LP=P.LocalPlayer;local C=W.CurrentCamera

-- Gráficos leves
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
local L=game:GetService("Lighting");L.GlobalShadows=false;L.FogEnd=1e9;L.Brightness=0;L.EnvironmentDiffuseScale=0;L.EnvironmentSpecularScale=0;L.OutdoorAmbient=Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end end

-- Otimizar mapa (remove só decos)
local nomesDeco={"tree","arvore","plant","bush","folha","leaf","palm","rock","pedra","decor","prop"}
local function isDeco(o) for _,n in ipairs(nomesDeco) do if o.Name:lower():find(n) then return true end end return false end
local function opt(o) if o:IsDescendantOf(LP.Character) then return end
if o:IsA("BasePart") then o.Material=Enum.Material.Plastic;o.Reflectance=0;o.CastShadow=false;if isDeco(o) then o:Destroy() end
elseif o:IsA("Decal") or o:IsA("Texture") then o:Destroy()
elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then o.Enabled=false;o:Destroy()
elseif (o:IsA("Model") or o:IsA("Folder")) and isDeco(o) then o:Destroy() end end
for _,v in ipairs(W:GetDescendants()) do opt(v) end
W.DescendantAdded:Connect(function(v) task.wait();opt(v) end)

-- Limpar roupas/acessórios
local function cleanChar(c) if c==LP.Character then return end;for _,v in ipairs(c:GetDescendants()) do if v:IsA("Accessory") or v:IsA("Clothing") then v:Destroy() end end end
for _,p in ipairs(P:GetPlayers()) do if p.Character then cleanChar(p.Character) end end
P.PlayerAdded:Connect(function(p)p.CharacterAdded:Connect(cleanChar)end)

-- Painel FPS
local gui=Instance.new("ScreenGui",LP.PlayerGui);gui.ResetOnSpawn=false
local lbl=Instance.new("TextLabel",gui);lbl.Size=UDim2.fromScale(0.1,0.05);lbl.Position=UDim2.new(0,10,0,10);lbl.BackgroundTransparency=1;lbl.TextColor3=Color3.fromRGB(0,255,0);lbl.Font=Enum.Font.SourceSansBold;lbl.TextSize=18
local c,lt=0,tick()
R.RenderStepped:Connect(function() c=c+1;if tick()-lt>=1 then lbl.Text="FPS: "..c;c=0;lt=tick() end end)

-- AIM ASSIST Head Aim (mantido igual)
local FOV=10;local assist=0.1
R.RenderStepped:Connect(function()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    local closest=FOV; local target
    for _,p in ipairs(P:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local head=p.Character:FindFirstChild("Head")
            if head then
                local pos,onscreen=C:WorldToViewportPoint(head.Position)
                if onscreen then
                    local center=Vector2.new(C.ViewportSize.X/2,C.ViewportSize.Y/2)
                    local dist=(Vector2.new(pos.X,pos.Y)-center).magnitude
                    if dist<closest then closest=dist; target=head.Position end
                end
            end
        end
    end
    if target then
        local dir=(target-C.CFrame.Position).Unit
        C.CFrame=CFrame.new(C.CFrame.Position,C.CFrame.Position+dir:Lerp(dir,assist))
    end
end)

-- ESP POR TEAM (Xerife / Assassino)
local function applyESP(player)
    if player==LP or not player.Character then return end
    if player.Character:FindFirstChild("RoleESP") then return end

    local h=Instance.new("Highlight")
    h.Name="RoleESP"
    h.Adornee=player.Character
    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency=1
    h.OutlineTransparency=0
    h.Parent=player.Character

    if player.Team then
        local t=player.Team.Name:lower()
        if t:find("murder") or t:find("assassin") then
            h.OutlineColor=Color3.fromRGB(255,0,0) -- Assassino
        elseif t:find("sheriff") then
            h.OutlineColor=Color3.fromRGB(0,120,255) -- Xerife
        else
            h:Destroy()
        end
    else
        h:Destroy()
    end
end

local function updateESP(player)
    if player.Character then task.wait(0.5);applyESP(player) end
end

for _,p in ipairs(P:GetPlayers()) do
    updateESP(p)
    p.CharacterAdded:Connect(function() updateESP(p) end)
end

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() updateESP(p) end)
end)
