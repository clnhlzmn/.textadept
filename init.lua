--require('elastic_tabstops').enable()
--require('spellcheck')
require('export')
--require('ctags')
_M.ctags = require('ctags')

textadept.editing.auto_pairs[string.byte('\'')] = nil

function SplitFilename(strFilename)
    -- Returns the Path, Filename, and Extension as 3 values
    return string.match(strFilename, "(.-)([^\\]-([^\\%.]+))$")
end

--buffer:set_theme('light', {font = 'Input', fontsize = 10})
buffer.tab_width = 4
buffer.view_ws = buffer.WS_VISIBLEALWAYS

function on_new_buffer()
    if buffer.encoding == nil then 
        buffer.representation[string.char(127)] = 'DEL'
        for i = 128, 255 do 
            buffer.representation[string.char(i)] = string.format('x%X', i) 
        end 
    end
    if buffer.filename then
        path, file, ext = SplitFilename(buffer.filename)
        file = string.upper(file)
        buffer.use_tabs = (file == 'GNUMAKEFILE' or file == 'MAKEFILE')
    end
    buffer.wrap_mode = buffer.WRAP_WHITESPACE
end

events.connect(
    events.BUFFER_AFTER_SWITCH, 
    on_new_buffer
)

events.connect(
    events.FILE_OPENED, 
    on_new_buffer
)

local encoding_menu = textadept.menu.menubar[_L['_Buffer']][_L['E_ncoding']]
encoding_menu[#encoding_menu + 1] = {'nil', function() buffer:set_encoding(nil); on_new_buffer() end}

keys['a&'] = textadept.menu.menubar[_L['_Search']]['_Ctags']['_Goto Ctag'][2]
keys['a,'] = textadept.menu.menubar[_L['_Search']]['_Ctags']['Jump _Back'][2]
keys['a.'] = textadept.menu.menubar[_L['_Search']]['_Ctags']['Jump _Forward'][2]
keys['ac'] = textadept.menu.menubar[_L['_Search']]['_Ctags']['_Autocomplete Tag'][2]

--for i = 128, 255 do
    --print(buffer.representation[string.char(i)])
--end

digits = {}
for i=0,9 do digits[i] = string.char(string.byte('0')+i) end
for i=10,36 do digits[i] = string.char(string.byte('A')+i-10) end

function numbertostring(number, base)
    if number < 0 then
        error("number must not be negative")
    end
    if base < 2 or base > 36 then
        error("base must be between 2 and 36")
    end
    local s = ""
    repeat
        local remainder = number % base
        s = digits[remainder]..s
        number = (number-remainder)/base
    until number==0
    return s
end

function chbase(n, f, t)
    if type(n) == 'string' then
        if type(f) ~= 'number' or type(t) ~= 'number' then 
            error('in chbase(n, f, t) where n is a string f and t must be numbers')
        end
        return numbertostring(tonumber(n, f), t)
    elseif type(n) == 'number' then
        if type(f) ~= 'number' then
            error('in chbase(n, t) where n is a number, t must be a number')
        end
        return numbertostring(n, f)
    else 
        error("n must be a string or a number")
    end
end

function logb(n, b)
    return math.log(n) / math.log(b)
end
