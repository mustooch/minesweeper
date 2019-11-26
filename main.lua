function makeBoard()
	tab = {}
	tab.BOMBS = {}
	-- make the list
	for y = 1, 16 do
		tab.BOMBS[y] = {}
		for x = 1, 16 do
			tab.BOMBS[y][x] = 0
		end
	end

	-- place BOMBS
	placed = 0
	while placed < BOMBS do
		randX = math.random(16)
		randY = math.random(16)
		if tab.BOMBS[randY][randX] == 0 then
			tab.BOMBS[randY][randX] = "x"
			placed = placed + 1
		end
	end

	-- put numbers around the BOMBS
	check = {
		{-1, -1}, { 0, -1}, { 1, -1},
		{-1,  0}, --[[   ]] { 1,  0},
		{-1,  1}, { 0,  1}, { 1,  1}
	}
	for i = 1, 16 do
		for j = 1, 16 do
			count = 0
			if tab.BOMBS[i][j] == 0 then
				for _, v in pairs(check) do
					x = v[1]
					y = v[2]
					dx = x + j
					dy = y + i
					if (dx > 0) and (dx <= 16) and (dy > 0) and (dy <= 16) then
						if tab.BOMBS[dy][dx] == "x" then
							count = count + 1
						end
					end
				end
				tab.BOMBS[i][j] = count
			end
		end
	end
	return tab
end

function drawBombs(tab)
	for i = 1, 16 do
		for j = 1, 16 do
			if tab.BOMBS[i][j] == "x" then
				love.graphics.draw(bombImg, 32+(j-1)*32, 32+(i-1)*32)
			else
				num = tab.BOMBS[i][j]
				love.graphics.draw(numberImg, numbers[num],
					32+(j-1)*32, 32+(i-1)*32)
			end
		end
	end
end

function drawIntro()
	love.graphics.setColor(rgb(192,192,192))
	love.graphics.rectangle("fill", 32,32, 512,512)
	love.graphics.setColor(0,0,0)
	love.graphics.print("press anywhere to start", 175, 256)
	love.graphics.setColor(1,1,1)
end

function makeHide()
	-- make the table to hide all the cells
	tab = {}
	for i = 1, 16 do
		tab[i] = {}
		for j = 1, 16 do
			tab[i][j] = true
		end
	end
	return tab
end

function hideBombs(tab)
	for i = 1, 16 do
		for j = 1, 16 do
			if tab.hide[i][j] == true then
				love.graphics.draw(emptyImg, 32+(j-1)*32, 32+(i-1)*32)
			elseif tab.hide[i][j] == "f" then
				love.graphics.draw(flagImg, 32+(j-1)*32, 32+(i-1)*32)
			end
		end
	end
end

function between(x1, y, x2)
	-- returns y if it is between x1 and x2
	if y >= x1 and y <= x2 then
		return y
	end
end

function clamp(x1, x2, x3)
	if x1 > x3 then return end
	if x2 > x3 then
		return x3
 	elseif x2 < x1 then
		return x1
	end
	return x2
end


function updateHide(tab, mx, my, button)
	cellX = between(1, math.floor(mx/32), 16)
	cellY = between(1, math.floor(my/32), 16)
	if cellX and cellY then
		if button == 1 then
			if tab.hide[cellY][cellX] == true then
				tab.hide[cellY][cellX] = false
			end
		elseif button == 2 then
			if tab.hide[cellY][cellX] == true then
				tab.hide[cellY][cellX] = "f"
				FLAGS = FLAGS - 1
			elseif tab.hide[cellY][cellX] == "f" then
				tab.hide[cellY][cellX] = true
				FLAGS = FLAGS + 1
			end
		end
	end
end

function drawWin()
	love.graphics.setColor(rgb(192,192,192))
	love.graphics.rectangle("fill", 32,32, 512,512)
	love.graphics.setColor(0,0,0)
	love.graphics.print("Congratulations\nYou Win!", 175, 256)
	love.graphics.setColor(1,1,1)
end

function touchMine(tab, mx,my, button)
	cellX = between(1, math.floor(mx/32), 16)
	cellY = between(1, math.floor(my/32), 16)
	if cellX and cellY then
		if button == 1 then
			if tab.BOMBS[cellY][cellX] == "x" then
				return true
			end
		end
	end
end

function drawFlagCount()
	flagText = FLAGS >= 10 and FLAGS or "0"..FLAGS
	love.graphics.print(tostring(flagText), 597, 153)
end

function drawTimer()
	timeText = ""
	if math.floor(TIME-delta) < 10 then
		timeText = "00"..tostring(math.floor(TIME-delta))
	elseif math.floor(TIME-delta) < 100 then
		timeText = "0"..tostring(math.floor(TIME-delta))
	end
	love.graphics.print(timeText, 591, 399)
end

function flagOnBomb(tab)
	count = 0
	for i=1, 16 do
		for j=1, 16 do
			if tab.hide[i][j] == "f" and tab.BOMBS[i][j] == "x" then
				count = count + 1
			end
		end
	end
	return count
end

function revealBlanks(tab, mx, my)
	cellX = between(1, math.floor(mx/32), 16)
	cellY = between(1, math.floor(my/32), 16)
	if cellX and cellY then

	end
end

function love.load()
	math.randomseed(os.time())
	function rgb(r,g,b)
		return {r/255,g/255,b/255}
	end

	STATE = "intro"
	BOMBS = 40
	FLAGS = BOMBS
	TIME = 0
	timerIsOn = true
	delta = 0

	font = love.graphics.setNewFont(20)
	bgImg = love.graphics.newImage("background.png")
	bombImg = love.graphics.newImage("bomb.png")
	emptyImg = love.graphics.newImage("empty.png")
	numberImg = love.graphics.newImage("numbers.png")
	flagImg = love.graphics.newImage("flag.png")
	numbers = {}
	for i = 0, 8 do
		numbers[i] = love.graphics.newQuad(i*32,0, 32,32,
			numberImg:getDimensions())
	end

	board = nil
end

function love.update(dt)
	if timerIsOn then
		TIME = TIME + dt
	end
end

function love.keypressed(key)
	if key == "escape" then love.event.push("quit") end
end

function love.mousepressed(mx, my, button)
	if STATE == "intro" then
		board = makeBoard()
		board.hide = makeHide()
		delta = TIME
		STATE = "playing"
	elseif STATE == "playing" then
		updateHide(board, mx, my, button)
		if touchMine(board, mx, my, button) then
			STATE = "gameover"
			timerIsOn = false
		elseif flagOnBomb(board) == BOMBS then
			STATE = "win"
			timerIsOn = false
		end
	elseif STATE == "gameover" then
		love.load()
	elseif STATE == "win" then
		love.event.push("quit")
	end
end

function love.draw()
	love.graphics.draw(bgImg)
	if STATE == "intro" then
		drawIntro()
	elseif STATE == "playing" then
		drawBombs(board)
		hideBombs(board)
		drawFlagCount()
		drawTimer()
	elseif STATE == "gameover" then
		drawBombs(board)
		drawTimer()
	elseif STATE == "win" then
		drawWin()
		drawTimer()
	end
end
