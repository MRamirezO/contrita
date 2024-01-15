function abs_box(s)
    local box = {}
    box.x1 = s.box.x1 + s.x
    box.y1 = s.box.y1 + s.y
    box.x2 = s.box.x2 + s.x
    box.y2 = s.box.y2 + s.y
    return box
end

function collide(a,b)
    local box_a = abs_box(a)
    local box_b = abs_box(b)

    if box_a.x1 > box_b.x2 or
        box_a.y1 > box_b.y2 or
        box_b.x1 > box_a.x2 or
        box_b.y1 > box_a.y2 then
        return false
    end
    return true
end

function limit_speed(num,maximum)
    return mid(-maximum,num,maximum)
end