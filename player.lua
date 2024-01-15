
function player_death()
    lifes-=1
    if lifes <=0 then
        game_over()
    end
    player.invinsible=true
    player.dying = true
end

function shoot(flp)
    local x_speed = 3
    local y_speed = 0

    if btn(⬆️) then
        y_speed=-3
        if btn(➡️) then x_speed = 3
        elseif btn(⬅️) then x_speed = -3
        else x_speed = 0 end
    elseif btn(⬇️) then
        y_speed=3
        if btn(➡️) then x_speed = 3
        elseif btn(⬅️) then x_speed = -3
        else x_speed = 0 end
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
    if player.dying then
        player.sps={13,14,29,30}
    elseif btn(⬆️) then
        if player.running then player.sps={5,6,21,22} else player.sps={7,8,23,24} end
    elseif btn(⬇️) then
        if player.running then player.sps={11,12,27,28} else player.sps={9,10,25,26} end
    else
        player.sps={3,4,19,20}
    end
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
        if btn(⬇️) then
            player.y+=7
        else
            player.dy-=player.boost
        end
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
    if player.y>map_end and not player.invinsible then
        player_death()
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
