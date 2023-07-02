module HardwareAbstractions

using ControlSystemsBase, LinearAlgebra

export @periodically, chirp, show_measurements
export control, measure, inputrange, outputrange, isstable, isasstable, sampletime, bias, initialize, finalize, ninputs, noutputs, nstates

import Base: finalize
import ControlSystemsBase: sampletime, isstable, ninputs, noutputs, nstates


include("utilities.jl")

include("interface.jl")
include("interface_documentation.jl")
include("reference_generators.jl")
include("controllers.jl")

end # module
