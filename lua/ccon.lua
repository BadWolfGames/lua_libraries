--[[
	//Custos Object Notation concept.

	i = number
	s = string
	b = boolean
	{} = table

	test = {
		[0] = "string",
		["string"] = 15.6,
		[1] = 625,
		[v] = Vector(255, 255, 255),
		[c] = Color(255, 255, 255),
		["array"] = {
			[1] = "pew;",
			[2] = Entity(26),
		}
	}

	the above table should turn into something like this:
	{i0;sstring;sstring;i15.6;i1;i625;sv;v255,255,255;sc;c255,255,255;sarray;{i1;spew\;;i2;e26}}

	----

	License:
	This work is license under Apache License 2.0(http://www.apache.org/licenses/LICENSE-2.0)

	Information:
	This is some script to turn tables into strings so they can be stored in a database.
	I discontinued this because it was just a quick little thing I wanted to try to make myself.
	But it should work as of now; it was tested with Lua 5.2.

	Extra:
	If you find any bugs or have an improvement then feel free to make a bug report/poll request.
]]--
local pairs, tonumber, tostring, type = pairs, tonumber, tostring, type
local concat = table.concat
local find, sub, gsub, match, len = string.find, string.sub, string.gsub, string.match, string.len

local c = {}
c[encode] = {
	["number"] = function(v)
		return "i"..v..";"
	end,
	["string"] = function(v)
		local es, n = gsub(v, ";", "\\;")
		if n == 0 then
			return "s"..v..";"
		end
		return "x"..es..";"
	end,
	["boolean"] = function(v)
		if v then
			return "t;"
		end
		return "f;"
	end,

	["table"] = function(tbl)
		local t = type
		local encode = c.encode
		local o = {}
		o[#o+1] = "{"

		for k,v in pairs(tbl) do
			encode[t(k)](k)
			encode[t(v)](v)
		end

		o[#o+1] = "}"

		return concat(o)
	end,
}

c[decode] = {
	--decode table
	["{"] = function(s, i)
		local b = {}
		local index, k, v, ks, vs
		local decode = c.decode
		i = i + 1

		while true do
			ks = sub(s, i, i)
			index, k = decode[ks](s, i)
			i = index + 1

			vs = sub(s, i, i)
			index, v = decode[vs](s, i)
			i = index + 1

			b[k] = v

			if sub(s, i, i) == "}" then
				break
			end
			i = i+1

			if i >= len(s) then
				break
			end
		end

		return i,b
	end,

	--decode integer
	["i"] = function(s, i)
		local f, fs
		f = find(s, ";", i)
		fs = sub(s, i, f-1)

		return f, tonumber(fs)
	end,
	--decode escaped string
	["x"] = function(s, i)
		local f, fs, str
		f = find(s, "[^\\];", i)
		fs = sub(s, i, f)
		str = gsub(fs, "\\;", ";")

		return f, str
	end,
	--decode string
	["s"] = function(s, i)
		local f, fs
		f = find(s, ";", i)
		fs = sub(s, i, f)

		return f, fs
	end,
	--decode true
	["t"] = function(s, i)
		return i, true
	end,
	--decode false
	["f"] = function(s, i)
		return i, false
	end,
}

local con = {}
function con.encode(tbl)
	return c.encode["table"](tbl)
end

function con.decode(s)
	local i = 1

	local i,b = c.decode["{"](s, i)
	return b
end

return con
