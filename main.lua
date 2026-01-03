-- FPS BOOST + ESP PLAYERS + ESP ARMA

local P=game:GetService("Players")
local R=game:GetService("RunService")
local W=workspace
local L=game:GetService("Lighting")
local LP=P.LocalPlayer

-- ===== FPS BOOST =====
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

-- ===== ESP CORES =====
local TEAM_COLORS={
	Assassino=Color3.fromRGB(255,0,0),
	Xerife=Color3.fromRGB(0,120,255),
	Inocente=Color3.fromRGB(0,255,0)
}
local WEAPON_COLOR=Color3.fromRGB(255,255,0)

-- ===== ESP PLAYER =====
local function clearESP(char)
	for _,v in ipairs(char:GetChildren()) do
		if v:IsA("Highlight") then v:Destroy() end
	end
end

local function applyPlayerESP(p)
	if p==LP or not p.Character or not p.Team then return end
	local color=TEAM_COLORS[p.Team.Name]
	if not color then return end

	clearESP(p.Character)

	local h=Instance.new("Highlight")
	h.Name="ESP_PLAYER"
	h.Adornee=p.Character
	h.FillTransparency=1
	h.OutlineTransparency=0
	h.OutlineColor=color
	h.Parent=p.Character
end

-- ===== ESP ARMA =====
local function applyWeaponESP(tool)
	if not tool:IsA("Tool") then return end
	if tool:FindFirstChild("ESP_WEAPON") then return end

	local h=Instance.new("Highlight")
	h.Name="ESP_WEAPON"
	h.Adornee=tool
	h.FillTransparency=1
	h.OutlineTransparency=0
	h.OutlineColor=WEAPON_COLOR
	h.Parent=tool
end

-- arma no chão
for _,v in ipairs(W:GetDescendants()) do
	if v:IsA("Tool") then applyWeaponESP(v) end
end

W.DescendantAdded:Connect(function(v)
	task.wait()
	if v:IsA("Tool") then applyWeaponESP(v) end
end)

-- arma na mão do xerife
local function onChar(char,p)
	if p.Team and p.Team.Name=="Xerife" then
		for _,v in ipairs(char:GetChildren()) do
			if v:IsA("Tool") then applyWeaponESP(v) end
		end
		char.ChildAdded:Connect(function(v)
			if v:IsA("Tool") then applyWeaponESP(v) end
		end)
	end
end

-- ===== HANDLERS =====
for _,p in ipairs(P:GetPlayers()) do
	if p.Character then
		applyPlayerESP(p)
		onChar(p.Character,p)
	end
	p.CharacterAdded:Connect(function(c)
		task.wait(1)
		applyPlayerESP(p)
		onChar(c,p)
	end)
end

P.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(c)
		task.wait(1)
		applyPlayerESP(p)
		onChar(c,p)
	end)
end)
