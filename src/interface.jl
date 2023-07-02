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
abstract type AbstractProcess end
struct PhysicalProcess  <: AbstractProcess
end
struct SimulatedProcess <: AbstractProcess
end

function processtype end

## Function definitions =====================================================================
function outputrange end
function inputrange end
function isstable end
function isasstable end
function sampletime end
function bias end
function control end
function measure end
function initialize end
function finalize end
