-- vars
local visuals_enabled = false
local show_boxes_enabled = false
local show_tracers_enabled = false
local show_names_enabled = false
local aimbot_enabled = false
local aimbot_fov_size = 50
local aimbot_aim_part = "Head"
local aimbot_smoothness = 0
local show_fov = false
local aimbot_right_click = false
local aimbot_smoothness_enabled = false
local players_service = game:GetService("Players")
local run_service = game:GetService("RunService")
local visual_elements = {}

function init_visuals(player)
    if not visuals_enabled then return end
    if player == players_service.LocalPlayer then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid_root_part = character:WaitForChild("HumanoidRootPart")

    local box_visual = Drawing.new("Square")
    box_visual.Color = Color3.fromRGB(255, 255, 255)
    box_visual.Thickness = 2
    box_visual.Transparency = 1
    box_visual.Filled = false

    local tracer_visual = Drawing.new("Line")
    tracer_visual.Color = Color3.fromRGB(255, 255, 255)
    tracer_visual.Thickness = 1
    tracer_visual.Transparency = 1

    local name_visual = Drawing.new("Text")
    name_visual.Text = player.Name
    name_visual.Color = Color3.fromRGB(255, 255, 255)
    name_visual.Size = 20
    name_visual.Center = true
    name_visual.Outline = true
    name_visual.Transparency = 1

    visual_elements[player] = {box = box_visual, tracer = tracer_visual, name = name_visual}

    local function update_visuals()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box_visual.Visible = false
            tracer_visual.Visible = false
            name_visual.Visible = false
            return
        end

        local hrp_position, on_screen = workspace.CurrentCamera:WorldToViewportPoint(humanoid_root_part.Position)
        if on_screen then
            local top = workspace.CurrentCamera:WorldToViewportPoint(humanoid_root_part.Position + Vector3.new(0, 3, 0))
            local bottom = workspace.CurrentCamera:WorldToViewportPoint(humanoid_root_part.Position - Vector3.new(0, 3, 0))
            local size = Vector2.new(math.abs(top.X - bottom.X) * 1.5, math.abs(top.Y - bottom.Y) * 1.5)

            if show_boxes_enabled then
                box_visual.Size = size
                box_visual.Position = Vector2.new(hrp_position.X - size.X / 2, hrp_position.Y - size.Y / 2)
                box_visual.Visible = true
            else
                box_visual.Visible = false
            end

            if show_tracers_enabled then
                tracer_visual.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
                tracer_visual.To = Vector2.new(hrp_position.X, hrp_position.Y)
                tracer_visual.Visible = true
            else
                tracer_visual.Visible = false
            end

            if show_names_enabled then
                name_visual.Position = Vector2.new(hrp_position.X, hrp_position.Y - size.Y / 2 - 20)
                name_visual.Visible = true
            else
                name_visual.Visible = false
            end
        else
            box_visual.Visible = false
            tracer_visual.Visible = false
            name_visual.Visible = false
        end
    end

    run_service.RenderStepped:Connect(update_visuals)
end

function remove_visuals(player)
    if visual_elements[player] then
        visual_elements[player].box:Remove()
        visual_elements[player].tracer:Remove()
        visual_elements[player].name:Remove()
        visual_elements[player] = nil
    end
end

function add_visuals(player)
    player.CharacterAdded:Connect(function()
        init_visuals(player)
    end)
    player.CharacterRemoving:Connect(function()
        remove_visuals(player)
    end)
    if player.Character then
        init_visuals(player)
    end
end

players_service.PlayerAdded:Connect(add_visuals)

for _, player in pairs(players_service:GetPlayers()) do
    add_visuals(player)
end

function toggle_visuals(state)
    visuals_enabled = state
    if not state then
        for _, player in pairs(players_service:GetPlayers()) do
            remove_visuals(player)
        end
    else
        for _, player in pairs(players_service:GetPlayers()) do
            if player.Character then
                init_visuals(player)
            end
        end
    end
end

function toggle_aimbot(state)
    aimbot_enabled = state
end

function set_aimbot_fov(size)
    aimbot_fov_size = size
end

function set_aimbot_target(part)
    aimbot_aim_part = part
end

function set_aimbot_smoothness(value)
    aimbot_smoothness = value
end

function toggle_show_fov(state)
    show_fov = state
end

function toggle_smoothness(state)
    aimbot_smoothness_enabled = state
end

-- aimbot shit
local UserInputService = game:GetService("UserInputService")

function aimbot()
    if not aimbot_enabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local camera = workspace.CurrentCamera
    local mouse = game.Players.LocalPlayer:GetMouse()

    local closest_player = nil
    local closest_distance = aimbot_fov_size

    for _, player in pairs(players_service:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild(aimbot_aim_part) then
            local part = player.Character[aimbot_aim_part]
            local screen_pos, on_screen = camera:WorldToViewportPoint(part.Position)
            if on_screen then
                local distance = (Vector2.new(screen_pos.X, screen_pos.Y) - Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).magnitude
                if distance < closest_distance then
                    closest_distance = distance
                    closest_player = player
                end
            end
        end
    end

    if closest_player then
        local part = closest_player.Character[aimbot_aim_part]
        local screen_pos = camera:WorldToViewportPoint(part.Position)
        local target = Vector2.new(screen_pos.X, screen_pos.Y)

        local screen_center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local move = target - screen_center

        if aimbot_smoothness_enabled then
            local move_step = move / (aimbot_smoothness + 1)
            mousemoverel(move_step.X, move_step.Y)
        else
            mousemoverel(move.X, move.Y)
        end
    end
end

run_service.RenderStepped:Connect(aimbot)

local fov_circle = Drawing.new("Circle")
fov_circle.Color = Color3.fromRGB(255, 255, 255)
fov_circle.Thickness = 1
fov_circle.Transparency = 1
fov_circle.Filled = false

function update_fov_circle()
    if show_fov then
        local camera = workspace.CurrentCamera
        local mouse_pos = UserInputService:GetMouseLocation()
        fov_circle.Radius = aimbot_fov_size
        fov_circle.Position = Vector2.new(mouse_pos.X, mouse_pos.Y)
        fov_circle.Visible = true
    else
        fov_circle.Visible = false
    end
end

run_service.RenderStepped:Connect(update_fov_circle)

-- fluent lib stuff
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- creating window & tabs
local Window = Fluent:CreateWindow({
    Title = "Disrupt",
    SubTitle = "   v0.2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- possible dtc, change to false if script gets dtc
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    aimbot_tab = Window:AddTab({ Title = "Aimbot", Icon = "" }),
    visuals_tab = Window:AddTab({ Title = "Visuals", Icon = "" }),
}

do
    -- aimbot tab
    local enable_aimbot_cb = Tabs.aimbot_tab:AddToggle("EnableAimbot", { Title = "Enable", Default = false })
    enable_aimbot_cb:OnChanged(function(value)
        toggle_aimbot(value)
    end)

    local show_fov_cb = Tabs.aimbot_tab:AddToggle("ShowFovCheckbox", { Title = "Show FOV", Default = false })
    show_fov_cb:OnChanged(function(value)
        toggle_show_fov(value)
    end)

    local smoothness_cb = Tabs.aimbot_tab:AddToggle("SmoothnessCheckbox", { Title = "Smoothness", Default = false })
    smoothness_cb:OnChanged(function(value)
        toggle_smoothness(value)
    end)

    local aim_at_dropdown = Tabs.aimbot_tab:AddDropdown("AimPartDropDown", {
        Title = "Aim At",
        Values = {"Head", "HumanoidRootPart"},
        Multi = false,
        Default = 1,
        Callback = function(value)
            set_aimbot_target(value)
        end
    })

    local fov_size_slider = Tabs.aimbot_tab:AddSlider("FovSizeSlider", {
        Title = "FOV Size",
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Callback = function(value)
            set_aimbot_fov(value)
        end
    })

    local smoothness_slider = Tabs.aimbot_tab:AddSlider("SmoothnessSlider", {
        Title = "Smoothness",
        Default = 0,
        Min = 0,
        Max = 10,
        Rounding = 1,
        Callback = function(value)
            set_aimbot_smoothness(value)
        end
    })

    -- visuals tab
    local enable_visuals_cb = Tabs.visuals_tab:AddToggle("EnableVisuals", { Title = "Enable", Default = false })
    enable_visuals_cb:OnChanged(function(value)
        toggle_visuals(value)
    end)

    local enable_boxes_cb = Tabs.visuals_tab:AddToggle("EnableBoxes", { Title = "Boxes", Default = false })
    enable_boxes_cb:OnChanged(function(value)
        show_boxes_enabled = value
    end)

    local enable_tracers_cb = Tabs.visuals_tab:AddToggle("EnableTracers", { Title = "Tracers", Default = false })
    enable_tracers_cb:OnChanged(function(value)
        show_tracers_enabled = value
    end)

    local enable_names_cb = Tabs.visuals_tab:AddToggle("EnableNames", { Title = "Names", Default = false })
    enable_names_cb:OnChanged(function(value)
        show_names_enabled = value
    end)
end

Window:SelectTab(1)
