pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- calcgame by kisonecat
cartdata("kisonecat_calcgame_1")

theF = function (x) return 2*x + x*x - x*x*x end

width = 5
height = 5

level = 1
cx = 42
answer = 0

deadline = 0
score = 0
starttime = 0

function someF()
   local a = rnd(2)+1
   local b = rnd(0.1)+0.1
   local c = rnd(2)+1
   local d = rnd(0.1)+0.1
   local e = rnd(0.6)-0.3
   local g = rnd(2)-1
   local h = rnd(0.2)-0.1
   local s
   local t
   
   if (rnd(1) > 0.5) then
      s = 1
   else
      s = -1
   end

   if (rnd(1) > 0.5) then
      t = 1
   else
      t = -1
   end   
   
   return function(x)
      x = s*x
      return t*(a*sin(b*x) + c*cos(d*x) + e + g*x + h*x*x)
   end   
end

function x2px(x)
   return (x - 63.5) / 127 * width
end

function py2y(y)
   return 127 - (127 * y / height + 63.5)
end

function maxValue(f)
   local m = -height
   
   for x = 0, 127 do
      px = x2px(x)
      py = f(px)
      if py > m then
	 m = py
      end
   end
   
   return m
end

function randomF()
   local f = someF()

   local maxv = maxValue(f)
   local minv = -maxValue(function (x) return -f(x) end)

   return function(x)
      return 0.6 * height * (f(x) - minv) / (maxv - minv) - 0.3 * height
   end
end

function get_answer(f,cx)
   for i = 1, level do
      f = derivative(f)
   end

   px = x2px(cx)
   py = f(px)

   return py
end

function make_problem()
   local f
   local x
   local good = false
   
   while not good do
      f = randomF()
      x = rnd(100) + 16
      level = flr(rnd(3))
      if abs(get_answer(f,x)) > 1 then
	 theF = f
	 cx = x
	 deadline = time() + 5
	 starttime = time()
	 good = true
      end
   end

   return
end


function derivative(f)
   local epsilon = 0.1
   return function(x)
      return (f(x+epsilon) - f(x-epsilon)) / (2*epsilon)
   end
end

function _init()
   make_problem()
end

function pad(string,length)
   local r = string
   for i=1,length - #string do
      r = "0"..r
   end
   return r
end

function graph(f)
   local window = 256*(time() - starttime)

   clip(64 - window, 64 - window, 2*window, 2*window)
   
   -- draw x axis
   line(0, 63, 128, 63, 5)
   line(0, 64, 128, 64, 5)

   -- draw y axis
   line(63, 0, 63, 128, 5)
   line(64, 0, 64, 128, 5)   

   local tx = x2px(cx)
   local ty = f(tx)
   local cy = py2y(ty)

   -- draw graph
   clip(cx - window, 0, 2*window, 128)
   local oldy = 0
   local y = 0   
   for x = 0, 127 do
      px = x2px(x)
      py = f(px)
      oldy = y
      y = py2y(py)
      if x > 0 then
	 line(x-1,oldy,x,y,12)	 	 	 
      end
   end

   clip()

   primes = ""
   for i = 1,level do
      primes = primes .. "'"
   end

   local tx = x2px(cx)
   local ty = f(tx)
   local cy = py2y(ty)
   
   local mx = cx + 10
   local prompt = "f" .. primes .. "(x)     "
   if answer > 0 then
     prompt = "f" .. primes .. "(x) < 0?"
   end
   if answer < 0 then
     prompt = "f" .. primes .. "(x) > 0?"
   end
   
   if (mx + 4*#prompt > 128) then
      mx = cx - 4*#prompt - 10
   end
   for i = -1,1 do
      for j = -1,1 do
	 print(prompt, mx+i, cy - 2 + j, 0)
      end
   end
   print(prompt, mx, cy - 2, 7)   

   elapsed = flr(100 * (deadline - time()))
   if deadline < time() then
      elapsed = 0
   end
   
   print("score " .. pad(""..score,5) .. "           time " .. pad(""..elapsed,3), 5, 5, 7)
end

function _draw()
  cls()
  graph(theF)

  px = x2px(cx)
  py = theF(px)
  y = py2y(py)

  r = 5 + 1.3*sin(2.3*time())
  circ(cx, y, r, 8)

  if (abs(answer) > 1.0) then
     r = 5 + 1.3*sin(2.3*time())
     circ(cx, y+answer, r, 14)
  end
end

function check_answer()
   local py = get_answer(theF,cx)

   -- if it is close, give the win to the player
   if ((py * answer < 0) or (abs(py) < 0.1)) then
      return true
   end

   return false
end

function _update()
   if (abs(answer) <= 6) then   
      if (btn(2)) answer -= 1
      if (btn(3)) answer += 1
   end
   
   if (not btn(2) and not btn(3)) then
      if (abs(answer) > 6) then
	 result = check_answer()
	 if result then
	    -- play good sound
	    if (deadline > time()) then
	       score = score + ceil((deadline - time()) * 10)
	    end
	    make_problem()
	    sfx(1)	    
	 else
	    -- play bad sound
	    sfx(0)
	 end
	 answer = 0
      end

      answer /= 2
   end
end

__sfx__
000600000f220102200f20003330044300543004430054000340006400064000640018400184001840000000000000c4000b4000b4000b4000000000000000000000000000000000000000000000000000000000
000100000e0201702022020270200c220142301d23023230282302a230141301c130211302814030140381403e1503f1500000000000000000000000000000000000000000000000000000000000000000000000
