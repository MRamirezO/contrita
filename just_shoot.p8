pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--enemies
function respawn_enemies()
    local dir = -1
    local h = 0
    local seed = rnd(1)
    local x = -16
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
        sps={194,195,210,211},
        dx=-1*dir,
        dy=0,
        x=x,
        y=40*h,
        r=30,
        w=16,
        h=16,
        anim=0,
        frame=1,
        running=false,
        jumping=false,
        falling=false,
        sliding=false,
        landed=false,
        max_dx=2,
        max_dy=3,
        t=0,
        dead=false,
        box = {x1=0,y1=0,x2=16,y2=16}
    })
    -- printh("new enemy")
end

function enemy_shoot()
    -- local num = flr(rnd(#enemies)) + 1
    local enemy = enemies[#enemies]
    local speed = 3
    if enemy.dx < 0 then speed*=-1 end
    if not enemy.dead then
        local b = {
            sp=129,
            x=enemy.x+4,
            y=enemy.y+4,
            dx=speed,
            dy=0,
            box = {x1=2,y1=0,x2=5,y2=4}
        }
        add(enemy_bullets,b)
    end
end

function draw_enemy(e)
    local flp = false 
    if e.dx < 0 then flp = true end
    if flp then
        spr(e.sps[2],e.x,e.y,1,1,flp)
        spr(e.sps[1],e.x+8,e.y,1,1,flp)
        spr(e.sps[4],e.x,e.y+8,1,1,flp)
        spr(e.sps[3],e.x+8,e.y+8,1,1,flp)
    else
        spr(e.sps[1],e.x,e.y,1,1,flp)
        spr(e.sps[2],e.x+8,e.y,1,1,flp)
        spr(e.sps[3],e.x,e.y+8,1,1,flp)
        spr(e.sps[4],e.x+8,e.y+8,1,1,flp)
    end
end

function enemy_animate(e)
    local walking_sprites = {
        {194,195,210,211},
        {196,197,212,213},
        {198,199,214,215}
    }
    if time()-e.anim>.1 then
        e.sps=walking_sprites[e.frame]
        e.anim=time()
        if e.frame>=3 then
            e.frame=1
        else
            e.frame+=1
        end
    end
end
-->8
--main
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

    main_menu()
end

function start()
    _update = update_game
    _draw = draw_game
    music()
end

function main_menu()
    _update = update_menu
    _draw = draw_menu
end

function update_menu()
    if btnp(🅾️) or btnp(❎) then
        start()
    end
end

function draw_menu()
    map(16,0)
    print("-- press any button to start --",2,120,5)
end

function game_over()
    sfx(4)
    music(-1)
    _update = update_over
    _draw = draw_over
end

function update_over()
    if btnp(🅾️) or btnp(❎) then
        _init()
    end
end

function draw_over()
    cls()
    print("game over",40,50,4)
    print("final score: "..points,40,60,4)
    print(" press any button to start over ",2,80,3)
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
            if #shots >= 30 then deli(shots,1) end
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
-->8
--map
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

function draw_shots()
    local speed = 2
    local spread = 2.5
    for s in all(shots) do
        circfill(s.x+s.t,s.y-s.t,0,8)
        circfill(s.x,s.y-s.t,0,8)
        circfill(s.x-s.t,s.y-s.t,0,8)
        circfill(s.x+s.t*speed,s.y+s.t,2,8)
        circfill(s.x-s.t*speed,s.y+s.t,2,8)
        circfill(s.x,s.y+s.t,3,8)
        circfill(s.x+s.t*speed,s.y,0,2)
        circfill(s.x-s.t*speed,s.y,0,2)
        if s.t < spread then
            s.t+=0.6
        end        
    end
end
-->8
--player

function player_death()
    lifes-=1
    if lifes <=0 then
        game_over()
    else
        sfx(2)
        player.invinsible=true
    end
    player.dying = true
end

function shoot(flp)
    local x_speed = 3
    local y_speed = 0
    sfx(1)
    if btn(⬆️) then
        y_speed=-3
        -- if btn(➡️) then x_speed = 3
        -- elseif btn(⬅️) then x_speed = -3
        x_speed = 0
    elseif btn(⬇️) then
        y_speed=3
        -- if btn(➡️) then x_speed = 3
        -- elseif btn(⬅️) then x_speed = -3
        x_speed = 0
    else
        if flp then x_speed = -3 end
    end


    local b = {
        sp=128,
        x=player.x+4,
        y=player.y+4,
        dx=x_speed,
        dy=y_speed,
        box = {x1=2,y1=0,x2=5,y2=4}
    }
    add(bullets,b)
end

function draw_player()
    if player.flp then
        spr(player.sps[2],player.x,player.y,1,1,player.flp)
        spr(player.sps[1],player.x+8,player.y,1,1,player.flp)
        spr(player.sps[4],player.x,player.y+8,1,1,player.flp)
        spr(player.sps[3],player.x+8,player.y+8,1,1,player.flp)
    else
        spr(player.sps[1],player.x,player.y,1,1,player.flp)
        spr(player.sps[2],player.x+8,player.y,1,1,player.flp)
        spr(player.sps[3],player.x,player.y+8,1,1,player.flp)
        spr(player.sps[4],player.x+8,player.y+8,1,1,player.flp)
    end
end

function player_update()

    if player.invinsible then
        player.t+=1
        if player.t > 60 and player.dying then -- dying delay
            player.dying = false
            player.x=59
            player.y=59
            sfx(3)
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
        if (not btn(⬆️) and not btn(⬇️)) or player.jumping then
            player.dx-=player.acc
            player.running=true
            player.flp=true
        end
    end
    if btn(➡️) and not player.dying then
        if (not btn(⬆️) and not btn(⬇️)) or player.jumping then
            player.dx+=player.acc
            player.running=true
            player.flp=false
        end
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
    if btnp(🅾️) and not player.dying
    and player.landed then
        if btn(⬇️) then
            player.y+=7
        else
            player.dy-=player.boost
        end
        player.landed=false
    end

    if btnp(❎) and #bullets <3 and not player.dying then
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
    player_animate()

    --limit player to map
    if player.x<map_start then
        player.x=map_start
    end
    if player.x>map_end-player.w then
        player.x=map_end-player.w
    end
    if player.y>map_end and not player.invinsible then
        player_death()
    end
    
end

function player_animate()
    local idle_sprites = {
        {1,2,17,18},
        {3,4,19,20},
        {5,6,21,22}
    }
    local running_sprites = {
        {1,2,17,18},
        {7,8,23,24},
        {9,10,25,26},
        {11,12,27,28},
        {13,14,29,30}
    }

    if player.dying then
        player.sps={46,47,62,63}
    elseif btn(⬆️) then
        player.sps={33,34,49,50}
    elseif btn(⬇️) then
        player.sps={35,36,51,52}
    elseif player.running then
        if time()-player.anim>.3 then
            if player.frame>=5 then
                player.frame=1
            else
                player.frame+=1
            end
            player.sps=running_sprites[player.frame]
            player.anim=time()
        elseif player.invinsible then
            player.sps={16,16,16,16}
        end
    else --player idle
        if time()-player.anim>.3 then
            if player.frame>=3 then
                player.frame=1
            else
                player.frame+=1
            end
            player.sps=idle_sprites[player.frame]
            player.anim=time()
        elseif player.invinsible then
            player.sps={16,16,16,16}
        end
    end
end
-->8
--tools
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
__gfx__
00000000000000000001110000000000000111000000000000011100000000000001110000000000000111000000000000011100000000000001110000000000
00000000000011111111110000001111111111000000111111111100000011111111110000001111111111000000111111111100000011111111110000000000
00700700000111111111110000011111111111000001111111111100000111111111110000011111111111000001111111111100000111111111110000000000
0007700000111ffffff1000000111ffffff1000000111ffffff1000000111ffffff1000000111ffffff1000000111ffffff1000000111ffffff1000000000000
0007700001ff1f71f71f100001ff1f71f71f100001ff1fffffff100001ff1f71f71f100001ff1f71f71f100001ff1f71f71f100001ff1f71f71f100000000000
0070070001ff1f71f71f100001ff1f71f71f100001ff1fffffff100001ff1f71f71f100001ff1f71f71f100001ff1f71f71f100001ff1f71f71f100000000000
0000000000111fffffff100000111fffffff100000111fffffff100000111fffffff100000111fffffff100000111fffffff100000111fffffff100000000000
00000000000111111111100000011111111110000001111111111000000111111111100000011111111110000001111111111000000111111111100000000000
0000000000111111ff11000000111111ff11000000111111ff11000000011111ff11000000011111ff11000000011111ff11000000111111ff11000000000000
00000000018848811181105001888881118110000188888111811000001888811181100000018884118810050018888111811000018488881181500000000000
00000000018844455555555001884888888810500188488888881050001888488888100500018884455555550018884888881005018445555555500000000000
00000000018844ff5555ff5001884455555555500188445555555550001888445555555500018884ff5555f500188844555555550184ff55555f500000000000
00000000018888ff888ff150018844ff5555ff50018844ff5555ff500018884ff55555f500018888ff881ff50018884ff55555f50011ff8888ff500000000000
000000000011111111111000001111ff111ff050001111ff111ff0500001111ff1111ff500011111111110000001111ff1111ff5000111111111100000000000
00000000001cc1001cc10000001cc1001cc10000001cc1001cc10000000001cc1000000000001cc11cc10000000001cc1000000000001cc11cc1000000000000
00000000004444404444400000444440444440000044444044444000000004444400000000004444444440000000044444000000000044444444400000000000
00000000000000000001110000000000000111000000000000000000000000000000000066000000000000000000000000000000000000000000000000000000
00000000000011111555510000001111111111000000000000000044400000000000004466000000000000444000000000000044400000000000000000000000
00000000000111111155110000011111111111000000000000000444440000000000044466000000000004444400000000000444440000000000aaaaaaaa0000
0000000000111fffff55000000111ffffff10000000000000004444444000000000444446600000000044444440000000004444444000000000a00000000a000
0000000001ff1f11f15ff00001ff1f77f77f100000000000000444444440066000044444664000000004444444400000000444444440000000a0000000000a00
0000000001ff1f77f75ff00001ff1f11f11f1000000000000044444444446660004444446644400000444444444440000044444444444000000a00000000a000
0000000000111fffff55100000111ffff444100000000000000111f70f1666000001117066110000000111ffff110000000111f77f1100000000aaaaaaaa0000
000000000001111111551000000111111441100000000000000111f77f6660000001117766000000000111f77f000000000111f70f0000000000000000000111
0000000000111111ff55000000111111f441000000000000000018ff66660000000018f666000000000018f70f000000000018ffff0000000000000000000111
0000000001888881115ff00001888881ff511000000000000000088f666000000000088f6f00000000000888880000000000088f660000000000111101110110
0000000001888888884ff00001888888ff58100000000000000000886f00000000000088ff00000000000088f60000000000008866600000000188881fff1110
00000000018888888444100001888888855810000000000000000088f000000000000088f000000000000088f60000000000008866660000401888881f1f1110
000000000188888844441000018888888558100000000000000000ccc0000000000000ccc0000000000000cc66000000000000ccc66660004118888181f1f110
00000000001111111111100000111111f55110000000000000000ccccc00000000000ccccc00000000000ccc6600000000000ccccc6666004c11111181fff110
00000000001cc1001cc10000001cc100ff510000000000000000ccc0ccc000000000ccc0ccc000000000ccc066c000000000ccc0ccc666604c1ff8881f1f1110
0000000000444440444440000044444055554000000000000004440004440000000444000444000000044400664400000004440004446660411ff8881ff1f110
33333333333333339994499911777711111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
34334334bbbbbbbb9944999917777771111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3443443433bbbbb39449999977777777111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444003bbb304499999477777777111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
440440444403b3049999994477777777111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444994030499999944977777777111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40444044999404999994499917777771111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444999949999944999911777711111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa00008888000888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa0088888808888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaaaaa0088888800888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaa99a0088899800088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0aaa9aa0088898800008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00aaaa00008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eee77eeeeee77eee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee7777eeee7777ee0050000000000050005000000000005000500000000000500000000000000000000000000000000000000000000000000000000000000000
ee7700eeee7777ee0055000000000575005500000000057500550000000005750000000000000000000000000000000000000000000000000000000000000000
ee7700eeee7700ee0057500000005775005750000000577500575000000057750000000000000000000000000000000000000000000000000000000000000000
ee7700eeee7700ee0057750000057750005775000005775000577500000577500000000000000000000000000000000000000000000000000000000000000000
eee77eeeee7700ee0005555555555750000555555555575000055555555557500000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeee77eee08005133333b550000005133333b550000005133333b55000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee888051355335500000005133333b500000005133333b50000000000000000000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0800513553355500080051355335500088805135533550000000888888888000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0800517113317500888051355335550008005135533555000000583583588500000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0800517733377500080051711331750008005171133175000000517513357500000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee00805133333b500000805177333775000085517733377500000051573ee75500000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee000855511555500000085115551150000005111555111500000851155ee15000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000005515000000000005150555500000051550005555000080051505555000000000000000000000000000000000000000000000000000
eeeeeeeeeeeeeeee0000000555000000000000550000000000055500000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044444343434444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141000000000000414141414144444443444344434443434344434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044444443444344434443444444444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044434443444344434443434344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044434443444344434444444344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000041414141414141410000000044434343444343434443434344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000044444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000043434344434443444343434344434343000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000043444444434443444344444344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414143434344434343444343434344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424244444344434443444344444344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424243434344434443444343434344444344000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4242424242424242424242424242424244444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414144444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001a4701a4701a4701a470194701947019470194701847018470174701647016470154701347012470104700f4700e4700d4700c4700a47009470084700647005470034700247001470004700047000470
00010000254502545024450244502345023450234502245022450214502145020450204501f4501f4501e4501d4501d4501c4501c4501b4501a4501a450194501845018450174501645015450144501345012450
000200002a2502925029250282501a250282502725026250252501b250232502225021250202501f2501d2501c2501c2501b2501925018250162501625014250132501225011250102500f2500a2500a2500b250
000400000225005250082500c250112501425016250192501c2501e2502125024250272502a2502f2503325036250392503b2503e2503f2503c2003e2003e2002b2002f20033200372003a2003c2003e2003f200
000300002435024350243502435024350243501e3501e3501e3501e3501e3501e3501935019350193501935019350193501935019350193501535015350153501535015350153501535015350153501535015350
000a01120a0500c000000000000000000000000e050000000f0000f0001105014000140500d000110500e0000a0500d0000000000000000000d0000000000000000001100000000140000000011000000000b000
000a0111000000e0000f0501b0000f0000f0000f000100001305014000140001600016050120001905017000160500f0001300000000000000000000000000000000000000000000000000000000000000000000
__music__
01 05464344
02 06424344
