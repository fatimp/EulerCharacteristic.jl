using Euler
using XUnit

@testset "Test euler characteristics for known sets"  begin include("calculation.jl") end
@testset "Test euler characteristic tracker" begin include("tracker.jl") end
