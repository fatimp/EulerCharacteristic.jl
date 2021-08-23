array = rand(Bool, (300, 400, 500))
indices = CartesianIndices(array)
tracker = EulerTracker(array)

for i in 1:2000
    idx = rand(indices)
    tracker[idx] = true - tracker[idx]
end

@test euler_characteristic(tracker) == euler_characteristic(BitArray(tracker))
