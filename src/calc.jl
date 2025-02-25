vertices(array :: AbstractArray{Bool}) = sum(array)

function ortvec(:: Val{N}, i) where N
    vec = zeros(Int, N)
    vec[i] = 1

    return CartesianIndex(vec...) :: CartesianIndex{N}
end

function segments(array :: AbstractArray{Bool, N}) where N
    δ = [ortvec(Val(N), i) for i in 1:N]

    indices    = CartesianIndices(array)
    fidx, lidx = first(indices), last(indices)
    uidx       = oneunit(fidx)

    mapreduce(+, indices) do idx
        slice = array[idx:min(idx + uidx, lidx)]

        mapreduce(+, 1:N) do i
            idx2 = uidx + δ[i]
            (checkbounds(Bool, slice, idx2) && slice[uidx] && slice[idx2]) ? 1 : 0
        end
    end
end

function checkface(array :: AbstractArray{Bool, N},
                   δ1    :: CartesianIndex{N},
                   δ2    :: CartesianIndex{N}) where N
    uidx = array |> CartesianIndices |> first |> oneunit

    idx1 = uidx
    idx2 = uidx + δ1
    idx3 = uidx + δ2
    idx4 = uidx + δ1 + δ2

    return checkbounds(Bool, array, idx2) &&
        checkbounds(Bool, array, idx3) &&
        checkbounds(Bool, array, idx4) &&
        array[idx1] && array[idx2] && array[idx3] && array[idx4]
end

function faces(array :: AbstractArray{Bool, 3})
    indices    = CartesianIndices(array)
    fidx, lidx = first(indices), last(indices)
    uidx       = oneunit(fidx)

    mapreduce(+, indices) do idx
        slice = array[idx:min(idx + uidx, lidx)]

        checkface(slice, CartesianIndex(1, 0, 0), CartesianIndex(0, 1, 0)) +
            checkface(slice, CartesianIndex(1, 0, 0), CartesianIndex(0, 0, 1)) +
            checkface(slice, CartesianIndex(0, 1, 0), CartesianIndex(0, 0, 1))
    end
end

function volumes(array :: AbstractArray{Bool})
    indices    = CartesianIndices(array)
    fidx, lidx = first(indices), last(indices)
    uidx       = oneunit(fidx)

    mapreduce(+, fidx:(lidx - uidx)) do idx
        slice = array[idx:(idx + uidx)]
        all(isone, slice)
    end
end

"""
    euler_characteristic(array :: AbstractArray{Bool})

Calculate Euler characteristic for a set of points `S` on a regular
cubic or square grid. The points are defined by a binary array `array`
in such a manner that if `array[idx] == true` then `idx ∈ S`.
"""
function euler_characteristic end

euler_characteristic(array :: AbstractArray{Bool, 2}) =
    vertices(array) - segments(array) + volumes(array)

euler_characteristic(array :: AbstractArray{Bool, 3}) =
    vertices(array) - segments(array) + faces(array) - volumes(array)
