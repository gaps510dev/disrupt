--[[
                                                                                                                             
            dddddddd                                                                                                         
            d::::::d  iiii                                                                                     tttt          
            d::::::d i::::i                                                                                 ttt:::t          
            d::::::d  iiii                                                                                  t:::::t          
            d:::::d                                                                                         t:::::t          
    ddddddddd:::::d iiiiiii     ssssssssss   rrrrr   rrrrrrrrr   uuuuuu    uuuuuu ppppp   ppppppppp   ttttttt:::::ttttttt    
  dd::::::::::::::d i:::::i   ss::::::::::s  r::::rrr:::::::::r  u::::u    u::::u p::::ppp:::::::::p  t:::::::::::::::::t    
 d::::::::::::::::d  i::::i ss:::::::::::::s r:::::::::::::::::r u::::u    u::::u p:::::::::::::::::p t:::::::::::::::::t    
d:::::::ddddd:::::d  i::::i s::::::ssss:::::srr::::::rrrrr::::::ru::::u    u::::u pp::::::ppppp::::::ptttttt:::::::tttttt    
d::::::d    d:::::d  i::::i  s:::::s  ssssss  r:::::r     r:::::ru::::u    u::::u  p:::::p     p:::::p      t:::::t          
d:::::d     d:::::d  i::::i    s::::::s       r:::::r     rrrrrrru::::u    u::::u  p:::::p     p:::::p      t:::::t          
d:::::d     d:::::d  i::::i       s::::::s    r:::::r            u::::u    u::::u  p:::::p     p:::::p      t:::::t          
d:::::d     d:::::d  i::::i ssssss   s:::::s  r:::::r            u:::::uuuu:::::u  p:::::p    p::::::p      t:::::t    tttttt
d::::::ddddd::::::ddi::::::is:::::ssss::::::s r:::::r            u:::::::::::::::uup:::::ppppp:::::::p      t::::::tttt:::::t
 d:::::::::::::::::di::::::is::::::::::::::s  r:::::r             u:::::::::::::::up::::::::::::::::p       tt::::::::::::::t
  d:::::::::ddd::::di::::::i s:::::::::::ss   r:::::r              uu::::::::uu:::up::::::::::::::pp          tt:::::::::::tt
   ddddddddd   dddddiiiiiiii  sssssssssss     rrrrrrr                uuuuuuuu  uuuup::::::pppppppp              ttttttttttt  
                                                                                   p:::::p                                   
                                                                                   p:::::p                                   
                                                                                  p:::::::p                                  
                                                                                  p:::::::p                                  
                                                                                  p:::::::p                                  
                                                                                  ppppppppp              
]]
-- detecting executor, this is used for potential Solara or Wave support in the future
local executor_used = tostring(identifyexecutor())
if executor_used == "Synapse Z" then
    -- vars
    local visuals_enabled = false
    local show_boxes_enabled = false
    local show_tracers_enabled = false
    local show_names_enabled = false
    local show_skeleton_enabled = false
    local show_view_line_enabled = false
    local aimbot_enabled = false
    local aimbot_fov_size = 50
    local aimbot_aim_part = "Head"
    local aimbot_smoothness = 0
    local show_fov = false
    local aimbot_right_click = false
    local aimbot_smoothness_enabled = false
    local aimbot_prediction_enabled = false
    local aimbot_prediction_strength_x = 0
    local aimbot_prediction_strength_y = 0
    local aimbot_sticky_aim_enabled = false
    local user_input_service = game:GetService("UserInputService")
    local locked_target = nil
    local players_service = game:GetService("Players")
    local run_service = game:GetService("RunService")
    local visual_elements = {}
    local tp_behind_offset = 0
    local tp_behind_height = 6
    local teleporting = false
    local speed_multiplier = 0
    local speed_modifier_enabled = false

    function init_visuals(player)
        if not visuals_enabled then
            return
        end
        if player == players_service.LocalPlayer then
            return
        end

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

        local skeleton_lines = {}
        for i = 1, 6 do
            local line = Drawing.new("Line")
            line.Color = Color3.fromRGB(255, 255, 255)
            line.Thickness = 2.5
            line.Transparency = 1
            table.insert(skeleton_lines, line)
        end

        local view_line = Drawing.new("Line")
        view_line.Color = Color3.fromRGB(255, 255, 255)
        view_line.Thickness = 2.5
        view_line.Transparency = 1

        visual_elements[player] = {
            box = box_visual,
            tracer = tracer_visual,
            name = name_visual,
            skeleton = skeleton_lines,
            view_line = view_line
        }

        local function update_visuals()
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                box_visual.Visible = false
                tracer_visual.Visible = false
                name_visual.Visible = false
                for _, line in pairs(skeleton_lines) do
                    line.Visible = false
                end
                view_line.Visible = false
                return
            end

            local hrp_position, on_screen = workspace.CurrentCamera:WorldToViewportPoint(humanoid_root_part.Position)
            if on_screen then
                local top =
                    workspace.CurrentCamera:WorldToViewportPoint(humanoid_root_part.Position + Vector3.new(0, 3, 0))
                local bottom =
                    workspace.CurrentCamera:WorldToViewportPoint(humanoid_root_part.Position - Vector3.new(0, 3, 0))
                local size = Vector2.new(math.abs(top.X - bottom.X) * 1.5, math.abs(top.Y - bottom.Y) * 1.5)

                if show_boxes_enabled then
                    box_visual.Size = size
                    box_visual.Position = Vector2.new(hrp_position.X - size.X / 2, hrp_position.Y - size.Y / 2)
                    box_visual.Visible = true
                else
                    box_visual.Visible = false
                end

                if show_tracers_enabled then
                    tracer_visual.From =
                        Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
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

                if show_view_line_enabled and player.Character:FindFirstChild("Head") then
                    local head = player.Character:FindFirstChild("Head")
                    local head_pos = workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                    local forward_vector = player.Character.HumanoidRootPart.CFrame.LookVector * 2
                    local view_point = head.Position + forward_vector
                    local view_pos = workspace.CurrentCamera:WorldToViewportPoint(view_point)

                    view_line.From = Vector2.new(head_pos.X, head_pos.Y)
                    view_line.To = Vector2.new(view_pos.X, view_pos.Y)
                    view_line.Visible = true
                else
                    view_line.Visible = false
                end

                if show_skeleton_enabled and player.Character then
                    local parts = {
                        head = player.Character:FindFirstChild("Head"),
                        left_arm = player.Character:FindFirstChild("LeftUpperArm"),
                        right_arm = player.Character:FindFirstChild("RightUpperArm"),
                        left_leg = player.Character:FindFirstChild("LeftUpperLeg"),
                        right_leg = player.Character:FindFirstChild("RightUpperLeg"),
                        torso = player.Character:FindFirstChild("Torso") or
                            player.Character:FindFirstChild("UpperTorso")
                    }

                    if parts.head and parts.torso then
                        local head_pos = workspace.CurrentCamera:WorldToViewportPoint(parts.head.Position)
                        local torso_pos = workspace.CurrentCamera:WorldToViewportPoint(parts.torso.Position)

                        skeleton_lines[1].From = Vector2.new(head_pos.X, head_pos.Y)
                        skeleton_lines[1].To = Vector2.new(torso_pos.X, torso_pos.Y)
                        skeleton_lines[1].Visible = true

                        if parts.left_arm then
                            local left_arm_pos = workspace.CurrentCamera:WorldToViewportPoint(parts.left_arm.Position)
                            skeleton_lines[2].From = Vector2.new(torso_pos.X, torso_pos.Y)
                            skeleton_lines[2].To = Vector2.new(left_arm_pos.X, left_arm_pos.Y)
                            skeleton_lines[2].Visible = true
                        else
                            skeleton_lines[2].Visible = false
                        end

                        if parts.right_arm then
                            local right_arm_pos = workspace.CurrentCamera:WorldToViewportPoint(parts.right_arm.Position)
                            skeleton_lines[3].From = Vector2.new(torso_pos.X, torso_pos.Y)
                            skeleton_lines[3].To = Vector2.new(right_arm_pos.X, right_arm_pos.Y)
                            skeleton_lines[3].Visible = true
                        else
                            skeleton_lines[3].Visible = false
                        end

                        if parts.left_leg then
                            local left_leg_pos = workspace.CurrentCamera:WorldToViewportPoint(parts.left_leg.Position)
                            skeleton_lines[4].From = Vector2.new(torso_pos.X, torso_pos.Y)
                            skeleton_lines[4].To = Vector2.new(left_leg_pos.X, left_leg_pos.Y)
                            skeleton_lines[4].Visible = true
                        else
                            skeleton_lines[4].Visible = false
                        end

                        if parts.right_leg then
                            local right_leg_pos = workspace.CurrentCamera:WorldToViewportPoint(parts.right_leg.Position)
                            skeleton_lines[5].From = Vector2.new(torso_pos.X, torso_pos.Y)
                            skeleton_lines[5].To = Vector2.new(right_leg_pos.X, right_leg_pos.Y)
                            skeleton_lines[5].Visible = true
                        else
                            skeleton_lines[5].Visible = false
                        end
                    end
                else
                    for _, line in pairs(skeleton_lines) do
                        line.Visible = false
                    end
                end
            else
                box_visual.Visible = false
                tracer_visual.Visible = false
                name_visual.Visible = false
                for _, line in pairs(skeleton_lines) do
                    line.Visible = false
                end
                view_line.Visible = false
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
        player.CharacterAdded:Connect(
            function()
                init_visuals(player)
            end
        )
        player.CharacterRemoving:Connect(
            function()
                remove_visuals(player)
            end
        )
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

    -- aimbot shit
    function aimbot()
        if not aimbot_enabled then
            return
        end
        if not user_input_service:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            locked_target = nil
            return
        end

        local camera = workspace.CurrentCamera
        local mouse = game.Players.LocalPlayer:GetMouse()

        if locked_target and aimbot_sticky_aim_enabled then
            if locked_target.Character and locked_target.Character:FindFirstChild(aimbot_aim_part) then
                local part = locked_target.Character[aimbot_aim_part]
                local predicted_position = part.Position
                if aimbot_prediction_enabled then
                    local velocity = locked_target.Character.HumanoidRootPart.Velocity
                    predicted_position =
                        part.Position +
                        Vector3.new(
                            velocity.X * aimbot_prediction_strength_x * 0.1,
                            velocity.Y * aimbot_prediction_strength_y * 0.1,
                            0
                        )
                end
                local screen_pos = camera:WorldToViewportPoint(predicted_position)
                local target = Vector2.new(screen_pos.X, screen_pos.Y)
                local screen_center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                local move = target - screen_center

                if aimbot_smoothness_enabled then
                    local move_step = move / (aimbot_smoothness + 1)
                    mousemoverel(move_step.X, move_step.Y)
                else
                    mousemoverel(move.X, move.Y)
                end
                return
            else
                locked_target = nil
            end
        end

        local closest_player = nil
        local closest_distance = aimbot_fov_size

        for _, player in pairs(players_service:GetPlayers()) do
            if
                player ~= game.Players.LocalPlayer and player.Character and
                    player.Character:FindFirstChild(aimbot_aim_part)
             then
                local part = player.Character[aimbot_aim_part]
                local predicted_position = part.Position
                if aimbot_prediction_enabled then
                    local velocity = player.Character.HumanoidRootPart.Velocity
                    predicted_position =
                        part.Position +
                        Vector3.new(
                            velocity.X * aimbot_prediction_strength_x * 0.1,
                            velocity.Y * aimbot_prediction_strength_y * 0.1,
                            0
                        )
                end
                local screen_pos, on_screen = camera:WorldToViewportPoint(predicted_position)
                if on_screen then
                    local distance =
                        (Vector2.new(screen_pos.X, screen_pos.Y) -
                        Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)).magnitude
                    if distance < closest_distance then
                        closest_distance = distance
                        closest_player = player
                    end
                end
            end
        end

        if closest_player then
            locked_target = closest_player
            local part = closest_player.Character[aimbot_aim_part]
            local predicted_position = part.Position
            if aimbot_prediction_enabled then
                local velocity = closest_player.Character.HumanoidRootPart.Velocity
                predicted_position =
                    part.Position +
                    Vector3.new(
                        velocity.X * aimbot_prediction_strength_x * 0.1,
                        velocity.Y * aimbot_prediction_strength_y * 0.1,
                        0
                    )
            end
            local screen_pos = camera:WorldToViewportPoint(predicted_position)
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
            local mouse_pos = user_input_service:GetMouseLocation()
            fov_circle.Radius = aimbot_fov_size
            fov_circle.Position = Vector2.new(mouse_pos.X, mouse_pos.Y)
            fov_circle.Visible = true
        else
            fov_circle.Visible = false
        end
    end

    run_service.RenderStepped:Connect(update_fov_circle)

    local function save_config(path)
        local config = {
            visuals_enabled = visuals_enabled,
            show_boxes_enabled = show_boxes_enabled,
            show_tracers_enabled = show_tracers_enabled,
            show_names_enabled = show_names_enabled,
            show_skeleton_enabled = show_skeleton_enabled,
            show_view_line_enabled = show_view_line_enabled,
            aimbot_enabled = aimbot_enabled,
            aimbot_fov_size = aimbot_fov_size,
            aimbot_aim_part = aimbot_aim_part,
            aimbot_smoothness = aimbot_smoothness,
            show_fov = show_fov,
            aimbot_smoothness_enabled = aimbot_smoothness_enabled,
            aimbot_prediction_enabled = aimbot_prediction_enabled,
            aimbot_prediction_strength_x = aimbot_prediction_strength_x,
            aimbot_prediction_strength_y = aimbot_prediction_strength_y,
            aimbot_sticky_aim_enabled = aimbot_sticky_aim_enabled
        }
        local config_string = game:GetService("HttpService"):JSONEncode(config)
        writefile(path, config_string)
    end

    local function load_config(path)
        if isfile(path) then
            local config_string = readfile(path)
            local config = game:GetService("HttpService"):JSONDecode(config_string)
            visuals_enabled = config.visuals_enabled
            show_boxes_enabled = config.show_boxes_enabled
            show_tracers_enabled = config.show_tracers_enabled
            show_names_enabled = config.show_names_enabled
            show_skeleton_enabled = config.show_skeleton_enabled
            show_view_line_enabled = config.show_view_line_enabled
            aimbot_enabled = config.aimbot_enabled
            aimbot_fov_size = config.aimbot_fov_size
            aimbot_aim_part = config.aimbot_aim_part
            aimbot_smoothness = config.aimbot_smoothness
            show_fov = config.show_fov
            aimbot_smoothness_enabled = config.aimbot_smoothness_enabled
            aimbot_prediction_enabled = config.aimbot_prediction_enabled
            aimbot_prediction_strength_x = config.aimbot_prediction_strength_x
            aimbot_prediction_strength_y = config.aimbot_prediction_strength_y
            aimbot_sticky_aim_enabled = config.aimbot_sticky_aim_enabled
            toggle_visuals(visuals_enabled)
            toggle_aimbot(aimbot_enabled)
        end
    end

    local function loop_behind(target_player)
        teleporting = true
        local player = game.Players.LocalPlayer
    
        while teleporting do
            local target_character = target_player.Character
            local target_humanoid_root_part = target_character and target_character:FindFirstChild("HumanoidRootPart")
            local player_character = player.Character
            local player_humanoid_root_part = player_character and player_character:FindFirstChild("HumanoidRootPart")
    
            if player_humanoid_root_part and target_humanoid_root_part then
                local target_cframe = target_humanoid_root_part.CFrame
                local target_look_vector = target_cframe.LookVector
                local target_position = target_cframe.Position
                local new_position =
                    target_position - (target_look_vector * tp_behind_offset) + Vector3.new(0, tp_behind_height, 0)
                player_humanoid_root_part.CFrame = CFrame.new(new_position, new_position + target_look_vector)
            end
    
            task.wait()
        end
    end

    -- noclip code credit to https://scriptblox.com/script/Universal-Script-Noclip-5473
    local Noclip = nil
    local Clip = nil
    
    function noclip()
        Clip = false
        local function Nocl()
            if Clip == false and game.Players.LocalPlayer.Character ~= nil then
                for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if v:IsA('BasePart') and v.CanCollide and v.Name ~= floatName then
                        v.CanCollide = false
                    end
                end
            end
            wait(0.21) -- basic optimization
        end
        Noclip = game:GetService('RunService').Stepped:Connect(Nocl)
    end
    
    function clip()
        if Noclip then Noclip:Disconnect() end
        Clip = true
    end

    -- fluent lib stuff
    local Fluent =
        loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

    -- creating window & tabs
    local Window =
        Fluent:CreateWindow(
        {
            Title = "Disrupt",
            SubTitle = "   v0.7",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = true, -- possible dtc, change to false if script gets dtc
            Theme = "Dark",
            MinimizeKey = Enum.KeyCode.LeftControl
        }
    )

    local Tabs = {
        aimbot_tab = Window:AddTab({Title = "Aimbot", Icon = ""}),
        visuals_tab = Window:AddTab({Title = "Visuals", Icon = ""}),
        player_tab = Window:AddTab({Title = "Player", Icon = ""}),
        teleport_tab = Window:AddTab({Title = "Teleport", Icon = ""}),
        config_tab = Window:AddTab({Title = "Configs", Icon = ""})
    }

    do
        -- aimbot tab
        local enable_aimbot_cb = Tabs.aimbot_tab:AddToggle("EnableAimbot", {Title = "Enable", Default = false})
        enable_aimbot_cb:OnChanged(
            function(value)
                aimbot_enabled = value
            end
        )

        local show_fov_cb = Tabs.aimbot_tab:AddToggle("ShowFovCheckbox", {Title = "Show FOV", Default = false})
        show_fov_cb:OnChanged(
            function(value)
                show_fov = value
            end
        )

        local smoothness_cb = Tabs.aimbot_tab:AddToggle("SmoothnessCheckbox", {Title = "Smoothness", Default = false})
        smoothness_cb:OnChanged(
            function(value)
                aimbot_smoothness_enabled = value
            end
        )

        local enable_prediction_cb =
            Tabs.aimbot_tab:AddToggle("EnablePrediction", {Title = "Enable Prediction", Default = false})
        enable_prediction_cb:OnChanged(
            function(value)
                aimbot_prediction_enabled = value
            end
        )

        local sticky_aim_cb = Tabs.aimbot_tab:AddToggle("StickyAimCheckbox", {Title = "Sticky Aim", Default = false})
        sticky_aim_cb:OnChanged(
            function(value)
                aimbot_sticky_aim_enabled = value
            end
        )

        local aim_at_dropdown =
            Tabs.aimbot_tab:AddDropdown(
            "AimPartDropDown",
            {
                Title = "Aim At",
                Values = {"Head", "HumanoidRootPart"},
                Multi = false,
                Default = 1,
                Callback = function(value)
                    aimbot_aim_part = value
                end
            }
        )

        local fov_size_slider =
            Tabs.aimbot_tab:AddSlider(
            "FovSizeSlider",
            {
                Title = "FOV Size",
                Default = 50,
                Min = 0,
                Max = 100,
                Rounding = 0,
                Callback = function(value)
                    aimbot_fov_size = value
                end
            }
        )

        local smoothness_slider =
            Tabs.aimbot_tab:AddSlider(
            "SmoothnessSlider",
            {
                Title = "Smoothness",
                Default = 0,
                Min = 0,
                Max = 10,
                Rounding = 1,
                Callback = function(value)
                    aimbot_smoothness = value
                end
            }
        )

        local prediction_strength_x_slider =
            Tabs.aimbot_tab:AddSlider(
            "PredictionStrengthXSlider",
            {
                Title = "Prediction Strength X",
                Default = 0,
                Min = 0,
                Max = 1,
                Rounding = 2,
                Callback = function(value)
                    aimbot_prediction_strength_x = value
                end
            }
        )

        local prediction_strength_y_slider =
            Tabs.aimbot_tab:AddSlider(
            "PredictionStrengthYSlider",
            {
                Title = "Prediction Strength Y",
                Default = 0,
                Min = 0,
                Max = 1,
                Rounding = 2,
                Callback = function(value)
                    aimbot_prediction_strength_y = value
                end
            }
        )

        -- visuals tab
        local enable_visuals_cb = Tabs.visuals_tab:AddToggle("EnableVisuals", {Title = "Enable", Default = false})
        enable_visuals_cb:OnChanged(
            function(value)
                toggle_visuals(value)
            end
        )

        local enable_boxes_cb = Tabs.visuals_tab:AddToggle("EnableBoxes", {Title = "Boxes", Default = false})
        enable_boxes_cb:OnChanged(
            function(value)
                show_boxes_enabled = value
            end
        )

        local enable_tracers_cb = Tabs.visuals_tab:AddToggle("EnableTracers", {Title = "Tracers", Default = false})
        enable_tracers_cb:OnChanged(
            function(value)
                show_tracers_enabled = value
            end
        )

        local enable_names_cb = Tabs.visuals_tab:AddToggle("EnableNames", {Title = "Names", Default = false})
        enable_names_cb:OnChanged(
            function(value)
                show_names_enabled = value
            end
        )

        local skeleton_esp_cb = Tabs.visuals_tab:AddToggle("SkeletonESP", {Title = "Skeleton", Default = false})
        skeleton_esp_cb:OnChanged(
            function(value)
                show_skeleton_enabled = value
            end
        )

        local view_line_esp_cb = Tabs.visuals_tab:AddToggle("ViewLineESP", {Title = "View Line", Default = false})
        view_line_esp_cb:OnChanged(
            function(value)
                show_view_line_enabled = value
            end
        )

        -- config tab
        local config_file_input =
            Tabs.config_tab:AddInput(
            "ConfigFileInput",
            {
                Title = "Config File Path",
                Default = "config.json",
                Numeric = false,
                Finished = false,
                Callback = function(value)
                    config_file_path = value
                end
            }
        )

        Tabs.config_tab:AddButton(
            {
                Title = "Save Config",
                Callback = function()
                    save_config(config_file_path or "config.json")
                end
            }
        )

        Tabs.config_tab:AddButton(
            {
                Title = "Load Config",
                Callback = function()
                    load_config(config_file_path or "config.json")
                end
            }
        )

        -- teleporting tab
        local teleport_target_input =
            Tabs.teleport_tab:AddInput(
            "TargetNameInput",
            {
                Title = "Player Name",
                Default = "",
                Numeric = false,
                Finished = true,
                Callback = function(input_value)
                    local input_value_lower = input_value
                    local matching_player = nil

                    -- matching name from input
                    for _, player in ipairs(game.Players:GetPlayers()) do
                        local player_name = player.Name and player.Name or ""
                        local player_display_name = player.DisplayName and player.DisplayName or ""

                        if
                            player_name:find(input_value_lower, 1, true) or
                                player_display_name:find(input_value_lower, 1, true)
                         then
                            matching_player = player
                            break
                        end
                    end

                    selected_player = matching_player
                end
            }
        )

        Tabs.teleport_tab:AddButton(
            {
                Title = "Loop Teleport To Player",
                Callback = function()
                    if selected_player then
                        loop_behind(selected_player)
                    end
                end
            }
        )

        Tabs.teleport_tab:AddButton(
            {
                Title = "Stop Teleporting To Player",
                Callback = function()
                    teleporting = false
                end
            }
        )

        -- player tab
        local enable_noclip_cb = Tabs.player_tab:AddToggle("EnableNoclip", {Title = "Noclip", Default = false})
        enable_noclip_cb:OnChanged(
            function(value)
                if value then
                    noclip()
                else
                    clip()
                end
            end
        )

        -- next update (you would only know about this if you read the source :3):
        -- local enable_fly_cb = Tabs.player_tab:AddToggle("EnableFly", {Title = "Fly", Default = false})
        -- enable_noclip_cb:OnChanged(
        --     function(value)
                
        --     end
        -- )

        local enable_speed_cb = Tabs.player_tab:AddToggle("EnableFly", {Title = "Enable Speed", Default = false})
        enable_speed_cb:OnChanged(
            function(value)
                speed_modifier_enabled = value
                if speed_modifier_enabled then
                    repeat
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame + game.Players.LocalPlayer.Character.Humanoid.MoveDirection * speed_multiplier
                        game:GetService("RunService").Stepped:wait()
                    until not speed_modifier_enabled
                end
            end
        )

        local walkspeed_multi_slider =
            Tabs.player_tab:AddSlider(
            "WalkspeedSlider",
            {
                Title = "Walkspeed",
                Default = 0,
                Min = 0,
                Max = 0.7,
                Rounding = 1,
                Callback = function(value)
                    speed_multiplier = value
                end
            }
        )
    end

    Window:SelectTab(1)
else
    if executor_used ~= "Synapse Z" then
        print("Only Synapse Z is supported, buy today at discord.gg/synz")
    end
end
