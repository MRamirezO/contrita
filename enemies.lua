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