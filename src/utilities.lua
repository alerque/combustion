local export = {}

---Extremley fast bin2c for LuaJIT
---@param data string
---@param symname string
local function bin2c_jit(data, symname)
    ---@type ffilib
    local ffi = require("ffi")

    local bufsiz = (#data * 8) + #("#include <stddef.h>\n\nconst unsigned char "..symname.."[] = {\n};\nconst size_t "..symname.."_size = "..#data..";\n")
    --Each hex byte is 4 characters, plus a comma, plus a newline every 16 bytes, plus the header and footer
    local buf = ffi.new("unsigned char [?]", bufsiz)
    local writtenc = 0
    local function concat(str)
        ffi.copy((buf + writtenc) --[[@as ffi.cdata*]], str)
        writtenc = writtenc + #str
    end

    concat("#include <stddef.h>\n\nconst unsigned char "..symname.."[] = {\n")

    for i = 1, #data do
        concat(string.format("0x%02x,", string.byte(data, i)))
        if i % 16 == 0 then
            concat("\n")
        end
    end


    concat("\n};\nconst size_t "..symname.."_size = "..#data..";\n")

    return ffi.string(buf, writtenc)
end


---@param data string
---@param symname string
---@return string
function export.bin2c(data, symname)
    if jit then
        print("\x1b[33mLuaJIT detected, using optimised bin2c\x1b[0m")
        return bin2c_jit(data, symname)
    end

    local out = "#include <stddef.h>\n\n"
    out = out.."const unsigned char "..symname.."[] = {\n"

    local time = os.time()
    io.write("\x1b[?25l")
    for i = 1, #data do
        out = out..string.format("0x%02x,", string.byte(data, i))
        io.write(string.format("\x1b[32mWrote \x1b[35m%d\x1b[32m bytes \x1b[0m(\x1b[35m%.2f%%\x1b[0m, \x1b[32mtaken\x1b[0m \x1b[35m%ds\x1b[0m)\r", i, i / #data * 100, os.time() - time))
        if i % 16 == 0 then
            out = out..'\n'
        end
    end
    io.write("\x1b[?25h")
    out = out.."\n};\n"
    return out.."const size_t "..symname.."_size = "..#data..";\n"
end

return export