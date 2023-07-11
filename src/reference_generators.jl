export PRBSGenerator

#PRBS
"""
    r = PRBSGenerator()
Generates a pseudo-random binary sequence. Call like `random_input = r()`.
"""
mutable struct PRBSGenerator
    state::Int
end

PRBSGenerator() = PRBSGenerator(Int(1))

function (r::PRBSGenerator)(args...)
    state = r.state
    bit   = ((state >> 0) ⊻ (state >> 2) ⊻ (state >> 3) ⊻ (state >> 5) ) & 1
    r.state = (state >> 1) | (bit << 15)
    bit
end

"""
    chirp(t, f0, f1, Tf; logspace = true)

Generate a logarithmic (default) or linear chirp signal betweem frequencies `f0` and `f1` over a time `Tf`.

A logarithmic chirp has roughly the same number of periods for each frequency, while a linear chirp spends roughly the same amount of time for each frequency. Most of the time, you want a logarithmic chirp, in order to get the same amount of information for each frequency.
"""
function chirp(t, f0, f1, Tf; logspace=true)
    f = logspace ? f0*(f1/f0)^(t/Tf) : f0 + t/Tf*(f1-f0)
    sin(2π*f*t)
end
