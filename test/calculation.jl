function genball(R)
    sphere_side = 2R + 1
    sphere = zeros(Bool, (sphere_side, sphere_side, sphere_side))

    for i in -R:R
        for j in -R:R
            for k in -R:R
                dist = i^2 + j^2 + k^2
                if dist < R^2
                    sphere[k+R+1, j+R+1, i+R+1] = 1
                end
            end
        end
    end

    return sphere
end

function gendisk(R)
    sphere  = zeros(Bool, (2R + 1, 2R + 1))

    for i in -R:R
        for j in -R:R
            dist = i^2 + j^2
            if dist < R^2
                sphere[j+R+1, i+R+1] = 1
            end
        end
    end

    return sphere
end

function gentorus(side, r, R)
    a = zeros(Bool, (side, side, side))
    for i in 1:side
        for j in 1:side
            for k in 1:side
                x = i - side÷2
                y = j - side÷2
                z = k - side÷2
                if (x^2 + y^2 + z^2 + R^2 - r^2)^2 < 4R^2*(x^2 + y^2)
                    a[k,j,i] = 1
                end
            end
        end
    end
    
    return a
end

@test euler_characteristic(genball(100)) == 1
@test euler_characteristic(gendisk(100)) == 1
@test euler_characteristic(ones(Bool, (100, 100, 100))) == 1
@test euler_characteristic(hcat(ones(Bool, (100, 100, 100)),
                                zeros(Bool, (100, 100, 100)),
                                ones(Bool, (100, 100, 100)))) == 2
let a = ones(Bool, (100, 100));
    a[50:60, 50:60] .= 0;
    @test euler_characteristic(a) == 0
end

let a = gentorus(200, 10, 90);
    b = cat(a[:,:,begin:end-5], a[:,:,begin+5:end]; dims = [3])
    @test euler_characteristic(b) == -1
end
