struct EulerTracker{T, N, A} <: AbstractArray{T, N}
    array     :: A
    euler     :: Ref{Int}
    predicate :: Function
end

function EulerTracker(array     :: AbstractArray{Bool, N},
                      predicate :: Function = identity) where N
    euler = array .|> predicate |> euler_characteristic

    return EulerTracker{Bool, N, typeof(array)}(array, Ref(euler), predicate)
end

function euler_locally(tracker :: EulerTracker{T, N},
                       index   :: CartesianIndex{N}) where {T, N}
    indices    = CartesianIndices(tracker)
    fidx, lidx = first(indices), last(indices)
    uidx       = oneunit(fidx)

    slice = tracker[max(fidx, index - uidx):min(lidx, index + uidx)]
    return slice .|> tracker.predicate |> euler_characteristic
end

function update_euler!(tracker :: EulerTracker{T, N},
                       val,
                       index   :: CartesianIndex{N}) where {T, N}
    token = AnnealingAPI.SimpleRollbackToken(tracker[index], index)

    tracker.euler[] -= euler_locally(tracker, index)
    tracker.array[index] = val
    tracker.euler[] += euler_locally(tracker, index)

    return token
end

# Array interface
Base.size(tracker :: EulerTracker) = size(tracker.array)
Base.getindex(tracker :: EulerTracker, idx :: Vararg{Int}) = tracker.array[idx...]
Base.setindex!(tracker :: EulerTracker, val, idx :: Vararg{Int}) =
    update_euler!(tracker, val, CartesianIndex(idx))
Base.copy(tracker :: EulerTracker) = tracker.array |> copy |> EulerTracker

# AnnealingAPI.jl interface
AnnealingAPI.update_corrfns!(tracker :: EulerTracker{T, N},
                             val,
                             idx     :: CartesianIndex{N}) where {T, N} =
                                 update_euler!(tracker, val, index)

# Other
euler_characteristic(tracker :: EulerTracker) = tracker.euler[]
