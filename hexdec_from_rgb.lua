return function(r, g, b)
    r = bit.band(bit.lshift(r, 16), 0xFF0000)
    g = bit.band(bit.lshift(g, 8), 0x00FF00)
    b = bit.band(b, 0x0000FF)
    return bit.bor(bit.bor(r, g), b)
end
