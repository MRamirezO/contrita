--variables

function _init()
    player={
        sp=1,
        x=59,
        y=59,
        w=16,
        h=16,
        flp=false,
        dx=0,
        dy=0,
        max_dx=2,
        max_dy=3,
        acc=0.5,
        boost=4,
        anim=0,
        running=false,
        jumping=false,
        falling=false,
        sliding=false,
        landed=false
    }
    bullets = {}
    gravity=0.2
    friction=0.85

    --simple camera
    cam_x=0

    --map limits
    map_start=0
    map_end=1024
end

function shoot(flp)
    local speed = 3
    if flp then speed*=-1 end
    local b = {
        sp=128,
        x=player.x,
        y=player.y,
        dx=speed,
        dy=0,
        box = {x1=2,y1=0,x2=5,y2=4}
    }
    add(bullets,b)
end

--update and draw

function _update()
    player_update()
    for b in all(bullets) do
        b.x+=b.dx
        b.y+=b.dy
        if b.x < 0 or b.x > 128 or
        b.y < 0 or b.y > 128 then
        del(bullets,b)
        end
        -- for e in all(enemies) do
        -- if col(b,e) then
        --     del(enemies,e)
        --     ship.p += 1
        --     explode(e.x,e.y)
        -- end
        -- end
    end
    -- player_animate()

    --simple camera
    -- cam_x=player.x-64+(player.w/2)
    -- if cam_x<map_start then
    --     cam_x=map_start
    -- end
    -- if cam_x>map_end-128 then
    --     cam_x=map_end-128
    -- end
    -- camera(cam_x,0)
    -- printh(#bullets)
end

function _draw()
    cls()
    map(0,0)
    spr(player.sp,player.x,player.y,1,1,player.flp)
    spr(2,player.x+8,player.y,1,1,player.flp)
    spr(17,player.x,player.y+8,1,1,player.flp)
    spr(18,player.x+8,player.y+8,1,1,player.flp)
    spr(33,player.x,player.y+16,1,1,player.flp)
    spr(34,player.x+8,player.y+16,1,1,player.flp)
    for b in all(bullets) do
        spr(b.sp,b.x,b.y)
    end
end

--collisions

function collide_map(obj,aim,flag)
    --obj = table needs x,y,w,h
    --aim = left,right,up,down

    local x=obj.x  local y=obj.y
    local w=obj.w  local h=obj.h

    local x1=0	 local y1=0
    local x2=0  local y2=0

    -- if aim=="left" then
    --     x1=x-1  y1=y
    --     x2=x    y2=y+h-1

    -- elseif aim=="right" then
    --     x1=x+w-1    y1=y
    --     x2=x+w  y2=y+h-1

    -- elseif aim=="up" then
    --     x1=x+2    y1=y-1
    --     x2=x+w-3  y2=y

    -- elseif aim=="down" then
    --     x1=x+2      y1=y+h
    --     x2=x+w-3    y2=y+h
    -- end

    x1=x+2      y1=y+h
    x2=x+w-3    y2=y+h

    --pixels to tiles
    x1/=8    y1/=8
    x2/=8    y2/=8

    if fget(mget(x1,y1), flag)
    or fget(mget(x1,y2), flag)
    or fget(mget(x2,y1), flag)
    or fget(mget(x2,y2), flag) then
        return true
    else
        return false
    end

end

--player

function player_update()
    --physics
    player.dy+=gravity
    player.dx*=friction

    --controls
    if btn(⬅️) then
        player.dx-=player.acc
        player.running=true
        player.flp=true
    end
    if btn(➡️) then
        player.dx+=player.acc
        player.running=true
        player.flp=false
    end

    --slide
    if player.running
    and not btn(⬅️)
    and not btn(➡️)
    and not player.falling
    and not player.jumping then
        player.running=false
        player.sliding=true
    end

    --jump
    if btnp(❎)
    and player.landed then
        player.dy-=player.boost
        player.landed=false
    end

    if btnp(🅾️) and #bullets <3 then
        shoot(player.flp)
    end

    --check collision up and down
    if player.dy>0 then
        player.falling=true
        player.landed=false
        player.jumping=false

        player.dy=limit_speed(player.dy,player.max_dy)

        if collide_map(player,"down",0) then
        player.landed=true
        player.falling=false
        player.dy=0
        player.y-=((player.y+player.h+1)%8)-1
        end
    elseif player.dy<0 then
        player.jumping=true
        -- if collide_map(player,"up",1) then
        -- player.dy=0
        -- end
    end

    --check collision left and right
    if player.dx<0 then

        player.dx=limit_speed(player.dx,player.max_dx)

        -- if collide_map(player,"left",1) then
        -- player.dx=0
        -- end
    elseif player.dx>0 then

        player.dx=limit_speed(player.dx,player.max_dx)

        -- if collide_map(player,"right",1) then
        -- player.dx=0
        -- end
    end

    --stop sliding
    if player.sliding then
        if abs(player.dx)<.2
        or player.running then
        player.dx=0
        player.sliding=false
        end
    end

    player.x+=player.dx
    player.y+=player.dy

    --limit player to map
    if player.x<map_start then
        player.x=map_start
    end
    if player.x>map_end-player.w then
        player.x=map_end-player.w
    end
end

-- function player_animate()
--     if player.jumping then
--         player.sp=7
--     elseif player.falling then
--         player.sp=8
--     elseif player.sliding then
--         player.sp=9
--     elseif player.running then
--         if time()-player.anim>.1 then
--         player.anim=time()
--         player.sp+=1
--         if player.sp>6 then
--             player.sp=3
--         end
--         end
--     else --player idle
--         if time()-player.anim>.3 then
--         player.anim=time()
--         player.sp+=1
--         if player.sp>2 then
--             player.sp=1
--         end
--         end
--     end
-- end

function limit_speed(num,maximum)
    return mid(-maximum,num,maximum)
end