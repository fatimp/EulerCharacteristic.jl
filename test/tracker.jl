equalto(x) = y -> y == x

array = rand(Bool, (300, 400, 500))
indices = CartesianIndices(array)

for fn in [equalto(true), equalto(false)]
    tracker = EulerTracker(array, fn)

    for i in 1:2000
        idx = rand(indices)
        tracker[idx] = true - tracker[idx]
    end

    @test euler_characteristic(tracker) == BitArray(tracker) .|> fn |> euler_characteristic
end
