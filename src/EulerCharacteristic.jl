module EulerCharacteristic

import AnnealingAPI

include("calc.jl")
include("tracker.jl")

export euler_characteristic,
    EulerTracker

end # module
