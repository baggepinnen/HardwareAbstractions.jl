export AbstractProcess, PhysicalProcess, SimulatedProcess
export  num_outputs,
        num_inputs,
        outputrange,
        inputrange,
        isstable,
        isasstable,
        sampletime,
        bias,
        control,
        measure,
        initialize,
        finalize

# Interface specification ===================================================================
abstract type AbstractProcess end
abstract type PhysicalProcess  <: AbstractProcess end
abstract type SimulatedProcess <: AbstractProcess end

## Function definitions =====================================================================
num_outputs(p::AbstractProcess) = error("Function not implemented for $(typeof(p))")
num_inputs(p::AbstractProcess)  = error("Function not implemented for $(typeof(p))")
outputrange(p::AbstractProcess) = error("Function not implemented for $(typeof(p))")
inputrange(p::AbstractProcess)  = error("Function not implemented for $(typeof(p))")
isstable(p::AbstractProcess)    = error("Function not implemented for $(typeof(p))")
isasstable(p::AbstractProcess)  = error("Function not implemented for $(typeof(p))")
sampletime(p::AbstractProcess)  = error("Function not implemented for $(typeof(p))")
bias(p::AbstractProcess)        = error("Function not implemented for $(typeof(p))")

control(p::AbstractProcess, u)  = error("Function not implemented for $(typeof(p))")
measure(p::AbstractProcess)     = error("Function not implemented for $(typeof(p))")

initialize(p::AbstractProcess)  = error("Function not implemented for $(typeof(p))")
finalize(p::AbstractProcess)    = error("Function not implemented for $(typeof(p))")
