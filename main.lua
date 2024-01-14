--variables

function _init()
    player={
        sps={1,2,17,18},
        t=0,
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
        landed=false,
        invinsible=false,
        dying=false,
        box = {x1=0,y1=0,x2=16,y2=16}
    }
    bullets = {}
    enemy_bullets={}
    enemies = {}
    gravity=0.2
    friction=0.85
    points = 0
    lifes=3

    --simple camera
    cam_x=0

    --map limits
    map_start=0
    map_end=1024

    start()
end

function start()
    _update = update_game
    _draw = draw_game
end

function game_over()
    _update = update_over
    _draw = draw_over
end

function update_over()

end

function draw_over()
    cls()
    print("game over",50,50,4)
end


function player_death()
    lifes-=1
    if lifes <=0 then
        game_over()
    end
    player.invinsible=true
    player.dying = true
end

function respawn_enemies()
    local dir = -1
    local h = 0
    local seed = rnd(1)
    local x = 0
    if seed<0.5 then 
        dir=1
        x = 128
    end

    if seed < 0.3 then
        h = 1
    elseif seed < 0.6 then
        h = 2
    end
    
    add(enemies, {
        sps={192,193,208,209},
        dx=-1*dir,
        dy=0,
        x=x,
        y=40*h,
        r=30,
        w=16,
        h=16,
        running=false,
        jumping=false,
        falling=false,
        sliding=false,
        landed=false,
        max_dx=2,
        max_dy=3,
        box = {x1=0,y1=0,x2=16,y2=16}
    })
    -- printh("new enemy")
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

function enemy_shoot()
    enemy = enemies[flr(rnd(#enemies)) + 1]
    local speed = 3
    if enemy.dx < 0 then speed*=-1 end
    local b = {
        sp=129,
        x=enemy.x,
        y=enemy.y,
        dx=speed,
        dy=0,
        box = {x1=2,y1=0,x2=5,y2=4}
    }
    add(enemy_bullets,b)
end

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

--update and draw

function update_game()
    player_update()
    for b in all(bullets) do
        b.x+=b.dx
        b.y+=b.dy
        if b.x < 0 or b.x > 128 or
        b.y < 0 or b.y > 128 then
        del(bullets,b)
        end
        for e in all(enemies) do
        if collide(b,e) then
            del(enemies,e)
            del(bullets,b)
            points += 1
            -- explode(e.x,e.y)
        end
        end
    end
    for b in all(enemy_bullets) do
        b.x+=b.dx
        b.y+=b.dy
        if b.x < 0 or b.x > 128 or
        b.y < 0 or b.y > 128 then
        del(bullets,b)
        end
        if collide(player,b) and not player.invinsible then
            player_death()
        end
    end
    for e in all(enemies) do
        e.dy+=gravity

        if e.dy>0 then
            e.falling=true
            e.landed=false
            e.jumping=false
    
            e.dy=limit_speed(e.dy,e.max_dy)
    
            if collide_map(e,"down",0) then
            e.landed=true
            e.falling=false
            e.dy=0
            e.y-=((e.y+e.h+1)%8)-1
            end
        end


        e.x+=e.dx
        e.y+=e.dy

        if (e.x+16) < 0 and e.dx < 0 or
        e.x > 128 and e.dx > 0 then
            del(enemies,e)
        end

        if collide(player,e) and not player.invinsible then
            player_death()
        end
    
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
    -- printh(#enemies)
    ⧗=time()
    if ⧗ % 2 == 0 then -- spawn every 2 seconds
        respawn_enemies()
    end
    if ⧗ % 3 == 0 then -- enemy shoot every 3 seconds
        enemy_shoot()
    end
    printh(player.invinsible)
end

function draw_enemy(e)
    spr(e.sps[1],e.x,e.y,1,1,e.flp)
    spr(e.sps[2],e.x+8,e.y,1,1,e.flp)
    spr(e.sps[3],e.x,e.y+8,1,1,e.flp)
    spr(e.sps[4],e.x+8,e.y+8,1,1,e.flp)
end

function draw_player()
    spr(player.sps[1],player.x,player.y,1,1,player.flp)
    spr(player.sps[2],player.x+8,player.y,1,1,player.flp)
    spr(player.sps[3],player.x,player.y+8,1,1,player.flp)
    spr(player.sps[4],player.x+8,player.y+8,1,1,player.flp)
end

function draw_game()
    cls()
    map(0,0)
    draw_player()
    for b in all(bullets) do
        spr(b.sp,b.x,b.y)
    end
    for b in all(enemy_bullets) do
        spr(b.sp,b.x,b.y)
    end
    for e in all(enemies) do
        draw_enemy(e)
    end
    print(points,9)
    for i=1,lifes do
        spr(130,80+10*i,3)
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

    if player.invinsible then
        player.t+=1
        if player.t > 60 and player.dying then -- dying delay
            player.dying = false
            player.x=59
            player.y=59
        end
        if player.t > 120 then -- invinsibility delay after respawn
            player.invinsible = false
            player.t = 0
        end
    end

    --physics
    player.dy+=gravity
    player.dx*=friction

    --controls
    if btn(⬅️) and not player.dying then
        player.dx-=player.acc
        player.running=true
        player.flp=true
    end
    if btn(➡️) and not player.dying then
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
    if btnp(❎) and not player.dying
    and player.landed then
        player.dy-=player.boost
        player.landed=false
    end

    if btnp(🅾️) and #bullets <3 and not player.dying then
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