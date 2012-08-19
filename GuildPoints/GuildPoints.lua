-- GLOBALS

dgp_Frame_IsMoving = false -- Is the frame currently moving

-- END GLOBALS


-- FRAMES

-- ** Main frame **
local dgp_Frame = CreateFrame("Frame", nil, UIParent) -- Create the Draqisfang Guild Points (dgp) parent frame
	
	-- Register events with the frame
	dgp_Frame:RegisterEvent("ADDON_LOADED") -- Triggered when saved variables are loaded
	dgp_Frame:RegisterEvent("PLAYER_LOGOUT") -- Triggered when the game is about to log out

	-- Set the frame attributes
	dgp_Frame:SetFrameStrata("BACKGROUND") -- Set the display layer
		-- Size and position are calculated by dgp_Resize_Frames() after the addon loads

	-- Set the texture of the parent frame	
	dgp_Frame:SetBackdrop({ bgFile = "Interface\\AddOns\\GuildPoints\\Images\\Main-Frame-Background",
		edgeFile = "Interface\\AddOns\\GuildPoints\\Images\\Main-Frame-Border",
		tile = false, tileSize = 0, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4} })

	-- Allow the frame to move
	dgp_Frame:SetMovable(true)

	-- Allow mouse interaction
	dgp_Frame:EnableMouse(true)

	-- Start with the parent window hidden
	dgp_Frame:Hide()
	
	
	-- ** Title frame (Top left of main frame) **
	local dgp_Title_Frame = CreateFrame("Button", nil, dgp_Frame) -- Create the Filter frame and attach it to the main frame
	-- This has been changed from a frame to a button to enable click and drag. Leaveing the label as a frame however
	
		-- Set the frame attributes
		dgp_Title_Frame:SetFrameStrata("LOW") -- Set the display layer
			-- Size and position are calculated by dgp_Resize_Frames() after the addon loads
			
		-- Set the texture of the filter frame
		dgp_Title_Frame:SetBackdrop({ bgFile = "Interface\\AddOns\\GuildPoints\\Images\\Title-Frame-Background",
			edgeFile = "Interface\\AddOns\\GuildPoints\\Images\\Main-Frame-Border",
			tile = false, tileSize = 0, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4} })
		
		-- Set the addon title 
		-- !!!! CURRENTLY NOT WORKING - Need to figure out how to title the button
		dgp_Guild_Name = GetGuildInfo("player")
		dgp_Title_Frame:SetText(dgp_Guild_Name .. " Guild Points")
		--print(dgp_Title_Frame:GetText())
		
		-- Register the frame for mouse clicks and define the action
		dgp_Title_Frame:RegisterForClicks("LeftButtonDown", "LeftButtonUp") -- Left button up and down are considered clicks
		dgp_Title_Frame:SetScript("OnClick", function(self)  dgp_Toggle_Move() end) -- Toggle UI movement when the frame is clicked
		
	-- ** End Title frame **
		
		
	-- ** Close button (Top right of main frame) **
	local dgp_Close_Button = CreateFrame("Button", nil, dgp_Frame) -- Create the Close Button frame and attach it to the main frame
		
		-- Set the button attributes
		dgp_Close_Button:SetFrameStrata("LOW") -- Set the display layer
			-- Size and position are calculated by dgp_Resize_Frames() after the addon loads
			
		-- Set the texture of the close button
		-- Border
		dgp_Close_Button:SetBackdrop({ bgFile = nil,
			edgeFile = "Interface\\AddOns\\GuildPoints\\Images\\Main-Frame-Border",
			tile = false, tileSize = 0, edgeSize = 16,
			insets = { left = 0, right = 0, top = 0, bottom = 0} })
		dgp_Close_Button:SetNormalTexture("Interface\\Addons\\GuildPoints\\Images\\Close-Button-Background")
		dgp_Close_Button:SetPushedTexture("Interface\\Addons\\GuildPoints\\Images\\Close-Button-Pressed")
		dgp_Close_Button:SetHighlightTexture("Interface\\Addons\\GuildPoints\\Images\\Close-Button-Highlight")

		-- Register the action for clicks
		dgp_Close_Button:SetScript("OnClick", function(self) dgpHide() end)
	
	-- ** End Close button **
	
	
	-- ** Bottom Frame (Everything below the title in the main frame) **
	local dgp_Bottom_Frame = CreateFrame("Button", nil, dgp_Frame) -- Create the bottom segment and attach it to the main frame
	-- This is made as a button to enable dragging, same as the title frame
	
		-- Set the frame attributes
		dgp_Bottom_Frame:SetFrameStrata("LOW") -- Set the display layer
			-- Size and poistion are calculated by dgp_Resize_Frames() after the addon loads
			
		-- Set the texture of the bottom frame
		dgp_Bottom_Frame:SetBackdrop({ bgFile = "Interface\\AddOns\\GuildPoints\\Images\\Title-Frame-Background",
			edgeFile = "Interface\\AddOns\\GuildPoints\\Images\\Main-Frame-Border",
			tile = false, tileSize = 0, edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4} })
		
		-- Register the frame for mouse clicks and define the action
		--dgp_Bottom_Frame:RegisterForClicks("LeftButtonDown", "LeftButtonUp") -- Left button up and down are considered clicks
		--dgp_Bottom_Frame:SetScript("OnClick", function(self)  dgp_Toggle_Move() end) -- Toggle UI movement when the frame is clicked
	
	
		-- ** Filter Editbox (Top Right of the 'Bottom Frame')
		local dgp_Filter_Editbox = CreateFrame("Frame", nil, dgp_Bottom_Frame)
			-- !!!! Currently set to a frame as there are issue witht he editbox
			
			-- Set the editbox attributes
			dgp_Filter_Editbox:SetFrameStrata("MEDIUM") -- Set the display layer
				-- Size and position are calculated by dgp_Resize_Frame()
				
			-- Set the texture of the filter editbox
			dgp_Filter_Editbox:SetBackdrop({ bgFile = "Interface\\AddOns\\GuildPoints\\Images\\Title-Frame-Background",
				edgeFile = "Interface\\AddOns\\GuildPoints\\Images\\Main-Frame-Border",
				tile = false, tileSize = 0, edgeSize = 16,
				insets = { left = 4, right = 4, top = 4, bottom = 4} })
			
			--dgp_Filter_Editbox:SetMaxLetters(30)
			--dgp_Filter_Editbox:SetTextInsets( 5, 5, 2, 2)
				
		-- ** End Filter editbox **
		
	-- ** End Bottom frame **
	
-- ** End Main frame **

-- END FRAMES

		
-- EVENT RECIEVE FUNCTIONS

-- Main frame
function dgp_Frame:OnEvent(event, arg1)
	-- When a addon loaded event is sent, then check if it's for this addon
	if event == "ADDON_LOADED" and arg1 == "GuildPoints" then
		-- Checks for the presence of the 5 backups and initialises them if they do not exist
		if DGPBackupNum1 == nil then
			DGPBackupNum1 = {}
			DGPBackupNum1.date = date("%d/%m/%y %H:%M:%S")
		end
		if DGPBackupNum2 == nil then
			DGPBackupNum2 = {}
			DGPBackupNum2.date = date("%d/%m/%y %H:%M:%S")
		end
		if DGPBackupNum3 == nil then
			DGPBackupNum3 = {}
			DGPBackupNum3.date = date("%d/%m/%y %H:%M:%S")
		end
		if DGPBackupNum4 == nil then
			DGPBackupNum4 = {}
			DGPBackupNum4.date = date("%d/%m/%y %H:%M:%S")
		end
		if DGPBackupNum5 == nil then
			DGPBackupNum5 = {}
			DGPBackupNum5.date = date("%d/%m/%y %H:%M:%S")
		end
		-- Also checks the saved frame sizes and position
		if DGPWidth == nil then
			DGPWidth = 400
		end
		if DGPHeight == nil then
			DGPHeight = 400
		end
		if DGPBottomOffset == nil then
			DGPBottomOffset = 500
		end
		if DGPLeftOffset == nil then
			DGPLeftOffset = 50
		end
		
		-- Now that the frame size and position exists we can set it
		dgp_Resize_Frames()
		
	end -- ADDON LOADED Guild Points
end -- dgp_Frame:OnEvent	
	
-- SLASH COMMANDS

-- Create and register slash commands
dgp_Frame:SetScript("OnEvent", dgp_Frame.OnEvent) -- Not sure what this exactly does yet, but it doesn't work without it

SLASH_GUILDPOINTS1 = "/dgp" -- Define a slash command to be used in game

-- Define what the slash command does (Not sure how it links to the slash command yet)
function SlashCmdList.GUILDPOINTS(msg)
	dgp_Frame:Show() -- Show the addon window
end -- SlashCmdList.GUILDPOINTS


-- FUNCTIONS

-- This function updates the frame sizes and positions
function dgp_Resize_Frames()
	-- Size and position the  main frame
	dgp_Frame:SetWidth(DGPWidth) -- Parent frame width
	dgp_Frame:SetHeight(DGPHeight) -- Parent frame height
	dgp_Frame:SetPoint("BOTTOM", 0, DGPBottomOffset) -- Offset the parent frame from the top of the screen
	dgp_Frame:SetPoint("LEFT", DGPLeftOffset, 0) -- Offset the parent frame from the left of the screen
	
		-- Size and position the title frame (Top-left of the main frame)
		local dgp_Parent = dgp_Title_Frame:GetParent() -- Hold a pointer to the parent frame
		dgp_Title_Frame:SetWidth(dgp_Parent:GetWidth() - 20) -- Title frame width 10 pixels less than the parent frame
		dgp_Title_Frame:SetHeight(25) -- Title frame height 1/10 of the parent frame
		dgp_Title_Frame:SetPoint("TOP", 0, 0) -- Position flush with the top of the parent frame
		dgp_Title_Frame:SetPoint("LEFT", 0, 0) -- Position flush with the left side
		
		-- Size and position the close button (Top-Right of the main frame)
		dgp_Parent = dgp_Close_Button:GetParent() -- Hold a pointer to the parent frame
		dgp_Close_Button:SetWidth(25) -- Close button width is 25
		dgp_Close_Button:SetHeight(25) -- Close button height is 25
		dgp_Close_Button:SetPoint("TOP", 0, 0) -- Position flush with the top of the parent frame
		dgp_Close_Button:SetPoint("RIGHT", 0, 0) -- Position flush with the right side
		
		-- Size and position the bottom frame (Everything below the title frame on the main frame
		dgp_Parent = dgp_Bottom_Frame:GetParent() -- Hold a pointer to the parent frame
		dgp_Bottom_Frame:SetWidth(dgp_Parent:GetWidth()) -- Bottom frame is the same width as the parent frame
		dgp_Bottom_Frame:SetHeight(dgp_Parent:GetHeight() - dgp_Title_Frame:GetHeight() + 5) -- Height is the same as the parent frame minus the title height
		dgp_Bottom_Frame:SetPoint("BOTTOM", 0, 0) -- Position flush with the bottom of the parent frame
		dgp_Bottom_Frame:SetPoint("LEFT", 0, 0) -- Postion flush with the left of the parent frame
		
			-- Size and position the filter editbox (Top right of the bottom frame)
			dgp_Parent = dgp_Bottom_Frame:GetParent() -- Hold a point to the parent frame
			dgp_Filter_Editbox:SetWidth(dgp_Parent:GetWidth() - 10) -- Filter editbox is 10 pixels less across than the parent frame
			dgp_Filter_Editbox:SetHeight(25) -- Filter editbox height is 25 pixels
			dgp_Filter_Editbox:SetPoint("TOP", 0, -5) -- Position 5 pixels from the top of the bottom frame
			dgp_Filter_Editbox:SetPoint("RIGHT", -5, 0) -- Position 5 pixels from the right of the bottom frame
			
end -- dgp_Resize_Frames


-- This is to show the addon windows
function dgpShow()
	dgp_Frame:Show() -- Show the addon window
end -- dgpShow


-- This is to hidw the addon window
function dgpHide()
	dgp_Frame:Hide() -- Hide the addon window
end -- dgpHide


-- This toggles the movement of the parent frame
function dgp_Toggle_Move()
	if dgp_Frame_IsMoving then -- If the frame is flagged as  moving
		dgp_Frame:StopMovingOrSizing() -- Stop moving the main frame
		dgp_Frame_IsMoving = false -- Flag the frame is no longer moving	
		DGPLeftOffset = dgp_Frame:GetLeft() -- Set the new horizontal position
		DGPBottomOffset = dgp_Frame:GetBottom() -- Set the new vertical position
	else -- If the frame is flagged as not moving
		dgp_Frame:StartMoving() -- Start moving the main frame
		dgp_Frame_IsMoving = true -- Flag the frame is now moving	
	end -- If dgp_Frame_IsMoving
end -- dgp_Toggle_Move


 -- Backup the guild public notes (used for storing Guild Points)
function dgpBackup()
	local counter = 1 -- Variable for counting
	
	-- Clear the last backup and store it in a temporary variable (To avoid a memory lose as tables aren't deleted till the game quits)
	wipe(DGPBackupNum5)
	local tempBackup = DGPBackupNum5
	-- Move all previous backups along the chain and delete the oldest
	DGPBackupNum5 = DGPBackupNum4
	DGPBackupNum4 = DGPBackupNum3
	DGPBackupNum3 = DGPBackupNum2
	DGPBackupNum2 = DGPBackupNum1
	
	SetGuildRosterShowOffline(true) -- Make sure offline members are shown
	
	local numMembers = GetNumGuildMembers() -- Retrieve the number of guild members (online number not required)
	
	-- Create a new backup in the first loctation
	
	DGPBackupNum1 = tempBackup -- Reuse the discarded table
	
	-- Cycle through all players in the guild
	while counter <= numMembers do
	
		-- Retrieve the players guild details up to officer note
		local name, rank, rankIndex, level, class, zone, note, officernote = GetGuildRosterInfo(counter)
		
		-- Make sure there is a note already
		if note == "" then -- If not...
			note = "GP: 0"
			if CanEditPublicNote() then
				GuildRosterSetPublicNote(counter, note) -- Then set one
			end -- endif
		end -- endif
		
		DGPBackupNum1[name] = note -- Store the GP in the table by name
		
		counter = counter + 1
	end -- While loop
	
	DGPBackupNum1.date = date("%d/%m/20%y at %H:%M:%S") -- Add a date to the table
	
	-- Notify the user that the backup was successful and of the backups that are present
	print("Backup successful")
	print("Current backups:")
	print(DGPBackupNum1.date)
	print(DGPBackupNum2.date)
	print(DGPBackupNum3.date)
	print(DGPBackupNum4.date)
	print(DGPBackupNum5.date)
end -- dgpBackup


-- Restore one of the 5 backups, determined by the argument passed to the function
function dgpRestore(num)
	local backupTable = {} -- variable to hold the data being restored
	local counter = 1 -- Variable for counting
	
	-- Make sure the player can edit public notes
	if CanEditPublicNote() then
	else
		-- Inform user that they cannot edit GP and stop the restore
		print("Unable to edit GP notes")
		return
	end -- endif
	
	-- Determine which backup to restore
	if	num == 1 then
		backupTable = DGPBackupNum1
	elseif	num == 2 then
		backupTable = DGPBackupNum2
	elseif	num == 3 then
		backupTable = DGPBackupNum3
	elseif	num == 4 then
		backupTable = DGPBackupNum4
	elseif num == 5 then
		backupTable = DGPBackupNum5
	else -- no valid backup number given
		print("Restore NOT successful")
		return
	end -- endif
	
	-- If there was a valid backup chosen then brgin the restore
	if backupTable == {} then
	else
		print("Restoring backup " .. backupTable.date) -- Inform the user which backup date has been chosen
		
		SetGuildRosterShowOffline(true) -- Make sure offline members are shown
	
		local numMembers = GetNumGuildMembers() -- Retrieve the number of guild members (online number not required)
		
		-- Cycle through all players in the guild
		while counter <= numMembers do
	
			-- Retrieve the players guild details up to officer note
			local name, rank, rankIndex, level, class, zone, note, officernote = GetGuildRosterInfo(counter)
			
			-- Check that the name is in the backup
			if backupTable[name] == nil then -- If it isn't...
				GuildRosterSetPublicNote(counter, "GP: 0") -- Set the Guild Points to 0
			else -- If it is...
				-- Check if there is any difference between the bacjup and the current GP
				if note == backupTable[name] then 
				else -- If there is...
					print(name .. ": " .. note .. " replaced with " .. backupTable[name]) -- Inform the user of the change that is to be made
					GuildRosterSetPublicNote(counter, backupTable[name]) -- Restore the GP
				end -- endif
			end -- endif
			
			counter = counter + 1
		end -- While loop
		print("Restore successful to " .. backupTable.date) -- Report which backup was successfully restored
	end -- endif
end -- dgpRestore


-- Compare the current GP with the requested backup
function dgpCompare(num)
	local backupTable = {} -- variable to hold the data being compared
	local counter = 1 -- Variable for counting
	
	-- Determine which backup to compare
	if	num == 1 then
		backupTable = DGPBackupNum1
	elseif	num == 2 then
		backupTable = DGPBackupNum2
	elseif	num == 3 then
		backupTable = DGPBackupNum3
	elseif	num == 4 then
		backupTable = DGPBackupNum4
	elseif num == 5 then
		backupTable = DGPBackupNum5
	else -- no valid backup number given
		print("No comparison available")
		return
	end -- endif
	
	-- If there was a valid backup chosen then begin the comparison
	if backupTable == {} then
	else
		print("Comparing with backup " .. backupTable.date) -- Inform the user which backup date has been chosen
		
		SetGuildRosterShowOffline(true) -- Make sure offline members are shown
	
		local numMembers = GetNumGuildMembers() -- Retrieve the number of guild members (online number not required)
		
		-- Cycle through all players in the guild
		while counter <= numMembers do
	
			-- Retrieve the players guild details up to officer note
			local name, rank, rankIndex, level, class, zone, note, officernote = GetGuildRosterInfo(counter)
			
			-- Check that the name is in the backup
			if backupTable[name] == nil then -- If it isn't...
				print(name .. " is new to the guild")
			else -- If it is...
				-- Check if there is any difference between the bacjup and the current GP
				if note == backupTable[name] then 
				else -- If there is...
					print(name .. ": " .. backupTable[name] .. " -> " .. note) -- Inform the user of the change since the backup
				end -- endif
			end -- endif
			
			counter = counter + 1
		end -- While loop
		print("Comparison with backup " .. backupTable.date .. " completed")
	end -- endif
end -- dgpCompare