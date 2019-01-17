local utilx = {}

function utilx.CheckType(arg, tp)
	if !arg or type(arg) != tp then
		return false
	else
		return arg
	end
end

--http://lua-users.org/wiki/SwitchStatement
function switch(t)
  t.case = function (self,x)
    local f=self[x] or self.default
    if f then
      if type(f)=="function" then
        return f(x,self)
      else
        error("case "..tostring(x).." not a function")
      end
    end
  end

  return t
end

--We return the string if no match is found.
function utilx.GetFileFromFilename(path)
	return path:match( "[\\/]([^/\\]+)$" ) or path
end

local function tblPrint(msg)
  print(msg)
end

--Helper function for PrintTableEx
function utilx.PrintTableEx(tbl, d)
	local out = ""

	if getmetatable(tbl) then --for extra compatibility with classes/metatables
		for i,t in pairs(getmetatable(tbl)) do
			if not (type(t) == "table") then
				if type(t) == "function" then
					out = out.."=> [%s] %s"
					tblPrint( out:format(i, tostring(t)))
				else
					out = out.."=> [%s] %s: %s"
					tblPrint( out:format(i, type(t),tostring(t)))
				end

				out = ""
			end
		end
	end

	for i,t in pairs(tbl) do
		if type(t) == "table" then
			tblPrint("=> ["..tostring(i).."] table {")
			utilx.PrintTableEx(t, 5)
			tblPrint("\t\t}", ply)
		else
			if d then
				local f = 0
				while f<d do
					out = out.."\t"
					f=f+1
				end
			end
			if type(t) == "function" then
				out = out.."=> [%s] %s"
				tblPrint( out:format(i, tostring(t)))
			else
				out = out.."=> [%s] %s: %s"
				tblPrint( out:format(i, type(t),tostring(t)))
			end
			out = ""
		end
	end
end

return utilx
