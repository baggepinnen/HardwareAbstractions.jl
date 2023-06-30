# This file contains all the docstrings so that the interface specification file is not cluttered

"""
    AbstractProcess
Base abstract type for all lab processes. This should not be inherited from directly, see [`PhysicalProcess`](@ref), [`SimulatedProcess`](@ref)
"""
AbstractProcess

"""
    PhysicalProcess <: AbstractProcess
Pysical processes should inherit from this abstract type.
"""
PhysicalProcess

"""
    SimulatedProcess <: AbstractProcess
Simulated processes should inherit from this abstract type.
"""
SimulatedProcess

"""
    ny = num_outputs(P::AbstractProcess)
Return the number of outputs (measurement signals) of the process.
"""
num_outputs

"""
    nu = num_inputs(P::AbstractProcess)
Return the number of inputs (control signals) of the process.
"""
num_inputs

"""
    range = outputrange(P::AbstractProcess)
Return the range of outputs (measurement signals) of the process. `range` is a vector of
tuples,  `length(range) = num_outputs(P), eltype(range) = Tuple(Real, Real)`
"""
outputrange

"""
    range = inputrange(P::AbstractProcess)
Return the range of inputs (control signals) of the process. `range` is a vector of
tuples,  `length(range) = num_inputs(P), eltype(range) = Tuple(Real, Real)`
"""
inputrange

"""
    isstable(P::AbstractProcess)
Return true/false indicating whether or not the process is stable
"""
isstable

"""
    isasstable(P::AbstractProcess)
Return true/false indicating whether or not the process is asymptotically stable
"""
isasstable

"""
    h = sampletime(P::AbstractProcess)
Return the sample time of the process in seconds.
"""
sampletime

"""
    b = bias(P::AbstractProcess)
Return an input bias for the process. This could be, i.e., the constant input u₀ around which
a nonlinear system is linearized, or whatever other bias might exist on the input.
`length(b) = num_inputs(P)`
"""
bias

"""
    control(P::AbstractProcess, u)
Send a control signal to the process. `u` must have dimension equal to `num_inputs(P)`
"""
control

"""
    y = measure(P::AbstractProcess)
Return a measurement from the process. `y` has length `num_outputs(P)`
"""
measure

"""
    initialize(P::AbstractProcess)
This function is called before any control or measurement operations are performed. During a call to `initialize`, one might set up external communications etc. After control is done,
the function [`finalize`](@ref) is called.
"""
initialize

"""
    finalize(P::AbstractProcess)
This function is called after any control or measurement operations are performed. During a call to `finalize`, one might finalize external communications etc. Before control is done,
the function [`initialize`](@ref) is called.
"""
finalize
