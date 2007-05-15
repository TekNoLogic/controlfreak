local major = "DongleFrames-1.0"
local minor = tonumber(string.match("$Revision: 249 $", "(%d+)") or 1)

assert(DongleStub, string.format("%s requires DongleStub.", major))
if not DongleStub:IsNewerVersion(major, minor) then return end

--[[-------------------------------------------------------------------------
  Library implementation
---------------------------------------------------------------------------]]

local lib = {}

-- Iterator written by Iriel taken from SecureStateHeader.lua
local function splitNext(sep, body)
    if (body) then
        local pre, post = string.split(sep, body, 2)
        if (post) then
            return post, pre
        end
        return false, body
    end
end
local function commaIterator(str) return splitNext, ",", str end
local function semicolonIterator(str) return splitNext, ";", str end
local function poundIterator(str) return splitNext, "#", str end

local function tonumberAll(...)
    local n = select("#",...)
    if n < 1 then return
    elseif n == 1 then return tonumber(...)
    else return tonumber((...)),tonumberAll(select(2,...)) end
end

local handlers

local function stripAttribute(name, attribs)
    local pattern = "#"..name
    if attribs:match(pattern.."#") or attribs:match(pattern.."$") then
        attribs = attribs:gsub(pattern,"")
        return nil,attribs
    else
        pattern = pattern.."=([^#]*)"
        local value = attribs:match(pattern)
        attribs = attribs:gsub(pattern,"")
        return value,attribs
    end
end

local function parseBaseAttributes(attribs)
    attribs = attribs:gsub("^#?","#")
    
    local name,attribs = stripAttribute("n",attribs)
    local template,attribs = stripAttribute("inh",attribs)
    local frameType,attribs = stripAttribute("t",attribs)
    local parent,attribs = stripAttribute("p",attribs)
    return frameType,parent,name,template,attribs
end

local function parseHandlerString(frame,handler,value)
    local t,method,regex = string.split(',',handler,3)
    if regex then value = value:match(regex) end
    if t == "number" then value = tonumber(value)
    elseif t == "bool" then value = value == "true" and true or false
    elseif t == "true" then value = true
    elseif t == "false" then value = false
    elseif t == "global" then value = getfenv(0)[value]
    end
    frame[method](frame,value)
end

function lib:Create(parent,attributes,...)
    local sp1
    if type(parent) ~= "table" then
        sp1 = attributes
        attributes = parent
        parent = nil
    end
    if type(attributes) ~= "string" then return end
    local objType,parent2,name,template,attributes = parseBaseAttributes(attributes)
    parent = parent or parent2
    if type(parent) == "string" then
        parent = getfenv(0)[parent]
    end
    
    local obj
    objType = objType and objType:lower() or "frame"
    if objType == "texture" then
        if not parent then return end -- TODO: Error here
        obj = parent:CreateTexture(name,nil,template)
    elseif objType == "fontstring" then
        if not parent then return end -- TODO: Error here
        obj = parent:CreateFontString(name,nil,template)
    else
        obj = CreateFrame(objType,name,parent,template)    
    end
    
    for _,section in poundIterator(attributes) do
        local attribute,value = section:match("^([^=]+)=?(.*)$")
        local handler = handlers[attribute]
        if type(handler) == "function" then handler(obj,value) 
        elseif type(handler) == "string" then
            for _,handlerString in poundIterator(handler) do
                parseHandlerString(obj,handlerString,value)
            end        
        end
    end
    
    if sp1 then
        obj:SetPoint(sp1,...)
    elseif select("#",...) > 0 then
        obj:SetPoint(...)
    end
    return obj
end

handlers = {
    size = "number,SetWidth,(%d+)%s*[%s,]%s*%d+#number,SetHeight,%d+%s*[%s,]%s*(%d+)",
    w = "number,SetWidth",
    h = "number,SetHeight",    
    movable = "true,SetMovable",
    mouse = "true,EnableMouse",
    hide = "true,Hide",
    clamp = "true,SetClampedToScreen",
    mousewheel = "true,EnableMouseWheel",
    toplevel = "true,SetToplevel",
    click = "string,RegisterForClicks",
    drag = "string,RegisterForDrag",
    strata = "string,SetFrameStrata",
    level = "number,SetFrameLevel",
    a = "number,SetAlpha",
    id = "number,SetID",
    scale = "number,SetScale",
    layer = "string,SetDrawLayer",
    text = "string,SetText",
	normtex = "string,SetNormalTexture",
    
    sap = function(frame, value)
        if value then value = getfenv(0)[value]
        else value = frame:GetParent() end
        if not value then return end
        frame:SetAllPoints(value)
    end,
    tex = function(texture,value)
        local r,g,b,a = value:match("^(%d?%.?%d*)%s*[,%s]%s*(%d?%.?%d*)%s*[,%s]%s*(%d?%.?%d*)$")
        if not r then
            r,g,b,a = value:match("^(%d?%.?%d*)%s*[,%s]%s*(%d?%.?%d*)%s*[,%s]%s*(%d?%.?%d*)%s*[,%s]%s*(%d?%.?%d*)$")
        end
        if r then 
            texture:SetTexture(tonumberAll(r,g,b),a and tonumber(a))
        else
            texture:SetTexture(value)
        end
    end,
    texc = function(texture,value)
        texture:SetTexCoord(tonumberAll(strsplit(',',value)))
    end,
}

--[[-------------------------------------------------------------------------
  Library implementation
---------------------------------------------------------------------------]]

function lib:GetVersion() return major,minor end

DongleStub:Register(lib)
