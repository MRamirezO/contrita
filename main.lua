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
        frame=1,
        running=false,
        jumping=false,
        falling=false,
        sliding=false,
        landed=false,
        invinsible=false,
        dying=false,
        box = {x1=4,y1=4,x2=10,y2=15}
    }
    bullets = {}
    enemy_bullets={}
    enemies = {}
    shots = {}
    gravity=0.2
    friction=0.85
    points = 0
    lifes=3

    --simple camera
    cam_x=0

    --map limits
    map_start=0
    map_end=128

    start()
end

function start()
    _update = update_game
    _draw = draw_game
end

function game_over()
    sfx(4)
    _update = update_over
    _draw = draw_over
end

function update_over()
    if btnp(4) then
        _init()
    end
end

function draw_over()
    cls()
    print("game over",40,50,4)
    print("final score: "..points,40,60,4)
    print("-- press o to start over --",10,80,4)
    player.sps={46,47,62,63}
    player.x=59
    player.y=100
    draw_player()
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
        if collide(b,e) and not e.dead then
            local s = {
                x=e.x+8,
                y=e.y+16,
                t=0
            }
            add(shots,s)
            e.dead=true
            e.sps={200,201,216,217}
            del(bullets,b)
            points += 1
            sfx(0)
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
        
        if not e.dead then
            e.x+=e.dx
            e.y+=e.dy
            enemy_animate(e)
        else
            e.t+=1
            if e.t > 60 then -- dying delay
                del(enemies,e)
            end
        end

        if (e.x+16) < 0 and e.dx < 0 or
        e.x > 128 and e.dx > 0 then
            del(enemies,e)
        end

        if collide(player,e) and not player.invinsible and not e.dead then
            player_death()
        end
        
    end
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
    if ⧗ % 3 == 0 and #enemies>=1 then -- enemy shoot every 3 seconds
        enemy_shoot()
    end
end

function draw_game()
    cls()
    map(0,0)
    draw_shots()
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