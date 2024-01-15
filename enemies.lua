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

function draw_enemy(e)
    spr(e.sps[1],e.x,e.y,1,1,e.flp)
    spr(e.sps[2],e.x+8,e.y,1,1,e.flp)
    spr(e.sps[3],e.x,e.y+8,1,1,e.flp)
    spr(e.sps[4],e.x+8,e.y+8,1,1,e.flp)
end