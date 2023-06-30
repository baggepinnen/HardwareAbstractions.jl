module HardwareAbstractions

using ControlSystemsBase, Parameters, DSP, LinearAlgebra

export @periodically, chirp
export control, measure, num_inputs, num_outputs, inputrange, outputrange, isstable, isasstable, sampletime, bias, initialize, finalize

import Base: finalize


include("utilities.jl")

include("interface.jl")
include("interface_documentation.jl")
include("reference_generators.jl")
include("controllers.jl")

end # module
