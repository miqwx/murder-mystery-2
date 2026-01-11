-- FPS BOOST + AIM ASSIST COMPACTO + ESP MM2
local P=game:GetService("Players");local R=game:GetService("RunService")
local W=workspace;local LP=P.LocalPlayer;local C=W.CurrentCamera

-- GRÁFICOS LEVES
pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
local L=game:GetService("Lighting")
L.GlobalShadows=false;L.FogEnd=1e9;L.Brightness=0
L.EnvironmentDiffuseScale=0;L.EnvironmentSpecularScale=0
L.OutdoorAmbient=Color3.new(0,0,0)
for _,v in ipairs(L:GetChildren()) do
if v:IsA("PostEffect") or v:IsA("Atmosphere") then v:Destroy() end
end

-- REMOVE DECORAÇÕES (ÁRVORES ETC)
local nomesDeco={"tree","arvore","plant","bush","folha","leaf","palm","rock","pedra","decor","prop"}
local function isDeco(o)
for _,n in ipairs(nomesDeco) do
if o.Name:lower():find(n) then return true end
end
return false
end
local function opt(o)
if LP.Character and o:IsDescendantOf(LP.Character) then return end
if o:IsA("BasePart") then
o.Material=Enum.Material.Plastic
o.Reflectance=0
o.CastShadow=false
if isDeco(o) then o:Destroy() end
elseif o:IsA("Decal") or o:IsA("Texture") then
o:Destroy()
elseif o:IsA("ParticleEmitter") or o:IsA("Trail")
or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles") then
o:Destroy()
elseif (o:IsA("Model") or o:IsA("Folder")) and isDeco(o) then
o:Destroy()
end
end
for _,v in ipairs(W:GetDescendants()) do opt(v) end
W.DescendantAdded:Connect(function(v) task.wait();opt(v) end)

-- LIMPA ROUPAS / ACESSÓRIOS
local function cleanChar(c)
if c==LP.Character then return end
for _,v in ipairs(c:GetDescendants()) do
if v:IsA("Accessory") or v:IsA("Clothing") then v:Destroy() end
end
end
for _,p in ipairs(P:GetPlayers()) do if p.Character then cleanChar(p.Character) end end
P.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(cleanChar) end)

-- FPS COUNTER
local gui=Instance.new("ScreenGui",LP.PlayerGui);gui.ResetOnSpawn=false
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

-- AIM ASSIST (NÃO ALTERADO)
local FOV=10;local assist=0.1
R.RenderStepped:Connect(function()
if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
local closest=FOV;local target
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

-- ESP XERIFE / ASSASSINO / INOCENTE (MM2)
local function applyESP(player)
if player==LP or not player.Character then return end
local char=player.Character

local isMurderer=false
local isSheriff=false

local function check(container)
for _,v in ipairs(container:GetChildren()) do
if v:IsA("Tool") then
local n=v.Name:lower()
if n:find("knife") then isMurderer=true end
if n:find("gun") then isSheriff=true end
end
end
end

check(player.Backpack)
check(char)

local color
if isMurderer then
color=Color3.fromRGB(255,0,0)
elseif isSheriff then
color=Color3.fromRGB(0,120,255)
else
color=Color3.fromRGB(0,255,0)
end

local h=char:FindFirstChild("RoleESP")
if not h then
h=Instance.new("Highlight")
h.Name="RoleESP"
h.Adornee=char
h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
h.FillTransparency=1
h.OutlineTransparency=0
h.Parent=char
end

h.OutlineColor=color
end

R.RenderStepped:Connect(function()
for _,p in ipairs(P:GetPlayers()) do applyESP(p) end
end)

-- AUTO TIRO NO ASSASSINO (SÓ QUANDO EU TENHO A ARMA)
local UIS = game:GetService("UserInputService")

local function getMurderer()
	for _,p in ipairs(P:GetPlayers()) do
		if p ~= LP and p.Character then
			for _,v in ipairs(p.Character:GetChildren()) do
				if v:IsA("Tool") and v.Name:lower():find("knife") then
					return p.Character
				end
			end
		end
	end
end

local function onTool(tool)
	if not tool:IsA("Tool") then return end
	if not tool.Name:lower():find("gun") then return end

	tool.Activated:Connect(function()
		local murderer = getMurderer()
		if murderer and murderer:FindFirstChild("Head") then
			local camPos = C.CFrame.Position
			local targetPos = murderer.Head.Position
			C.CFrame = CFrame.new(camPos, targetPos)
		end
	end)
end

-- quando pegar a arma
LP.CharacterAdded:Connect(function(char)
	char.ChildAdded:Connect(onTool)
end)

if LP.Character then
	LP.Character.ChildAdded:Connect(onTool)
end
