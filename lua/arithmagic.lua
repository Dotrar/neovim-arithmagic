
local M = {}

local function get_cursor_number()
    local oldkeyword = vim.o.iskeyword
    vim.o.iskeyword = oldkeyword .. ",.,-"
    local number = vim.fn.expand("<cword>")
    vim.o.iskeyword = oldkeyword
    return number
end

local function get_delta(value)
    local delta,_ = string.gsub(value,"%d","0")
    delta,_ = string.gsub(delta,"%d$","1")
    return delta
end

local function format_from(value)
    local point_position = string.find(value, "%.")
    local format = "0"
    if (point_position ~= nil) then
        format = #value - point_position
    end
    return "%" .. string.format(".%df",format)
end

local function change_value_on_line_near_cursor(oldvalue,newvalue)

    local pos = vim.api.nvim_win_get_cursor(0)[2]
    local line = vim.api.nvim_get_current_line()

    pos = math.max( pos - #oldvalue , 0)

    local baseline = line:sub(0,pos)
    local newline = line:sub(pos+1)

    newvalue = string.format(format_from(oldvalue),newvalue)
    newline = newline:gsub(oldvalue,newvalue,1)

    vim.api.nvim_set_current_line(baseline .. newline)
end

local function get_params ()
    local number_str = get_cursor_number()
    local number = tonumber(number_str)
    local delta = tonumber(get_delta(number_str))
    return number_str, number, delta
end

M.increment = function (multiplier)
    local nstr, number, delta = get_params()

    if(number == nil or delta == nil) then
        return
    end
    local new_value = number + (delta * (multiplier or 1))
    change_value_on_line_near_cursor(nstr, new_value)
end

M.decrement = function (multiplier)
    local nstr, number, delta = get_params()

    if(number == nil or delta == nil) then
        return
    end
    local new_value = number - (delta * (multiplier or 1))
    change_value_on_line_near_cursor(nstr, new_value)
end

local function multiply_value_in_buffer(amount )
    if (amount == nil) then return end

    local nstr  = get_cursor_number()
    local number = tonumber(nstr)
    if (number == nil) then return end

    local new_value = number * amount
    change_value_on_line_near_cursor(nstr, new_value)
end

M.multiply = function (value)
    value = tonumber(value)
    if (value == nil) then
        value = tonumber(vim.fn.input("Multipy by how much? "))
    end
    if (value == nil) then return end
    multiply_value_in_buffer(value)
end

return M
