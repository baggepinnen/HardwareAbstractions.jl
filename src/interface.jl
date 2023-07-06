export AbstractProcess, PhysicalProcess, SimulatedProcess, processtype
export  outputrange,
        inputrange,
        ninputs,
        noutputs,
        nstates,
        isstable,
        isasstable,
        sampletime,
        bias,
        control,
        measure,
        initialize,
        finalize

# Interface specification ===================================================================
"""
    AbstractProcess
Base abstract type for all lab processes. This should not be inherited from directly, see [`PhysicalProcess`](@ref), [`SimulatedProcess`](@ref)
"""
abstract type AbstractProcess end

"""
    PhysicalProcess <: AbstractProcess
Pysical processes should have this trait when queried with [`processtype`](@ref).
"""
struct PhysicalProcess  <: AbstractProcess
end

"""
    SimulatedProcess <: AbstractProcess
Simulated processes should have this trait when queried with [`processtype`](@ref).
"""
struct SimulatedProcess <: AbstractProcess
end

"""
    processtype(P::AbstractProcess)

Return the type of process `P`, either `PhysicalProcess` or `SimulatedProcess`.
"""
function processtype end

## Function definitions =====================================================================

"""
    range = outputrange(P::AbstractProcess)
Return the range of outputs (measurement signals) of the process. `range` is a vector of
tuples,  `length(range) = num_outputs(P), eltype(range) = Tuple(Real, Real)`
"""
function outputrange end

"""
    range = inputrange(P::AbstractProcess)
Return the range of inputs (control signals) of the process. `range` is a vector of
tuples,  `length(range) = num_inputs(P), eltype(range) = Tuple(Real, Real)`
"""
function inputrange end

"""
    isstable(P::AbstractProcess)
Return true/false indicating whether or not the process is stable
"""
function isstable end

"""
    isasstable(P::AbstractProcess)
Return true/false indicating whether or not the process is asymptotically stable
"""
function isasstable end

"""
    h = sampletime(P::AbstractProcess)
Return the sample time of the process in seconds.
"""
function sampletime end

"""
    b = bias(P::AbstractProcess)
Return an input bias for the process. This could be, i.e., the constant input u₀ around which
a nonlinear system is linearized, or whatever other bias might exist on the input.
`length(b) = num_inputs(P)`
"""
function bias end

"""
    control(P::AbstractProcess, u)
Send a control signal to the process. `u` must have dimension equal to `num_inputs(P)`
"""
function control end

"""
    y = measure(P::AbstractProcess)
Return a measurement from the process. `y` has length `num_outputs(P)`
"""
function measure end

"""
    initialize(P::AbstractProcess)
This function is called before any control or measurement operations are performed. During a call to `initialize`, one might set up external communications etc. After control is done,
the function [`finalize`](@ref) is called.
"""
function initialize end

"""
    finalize(P::AbstractProcess)
This function is called after any control or measurement operations are performed. During a call to `finalize`, one might finalize external communications etc. Before control is done,
the function [`initialize`](@ref) is called.
"""
function finalize end
