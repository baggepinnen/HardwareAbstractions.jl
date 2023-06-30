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

If `t` is a symbolic variable, a symbolic expression in `t` is returned.
"""
function chirp(t, f0, f1, Tf; logspace=true)
    f = logspace ? f0*(f1/f0)^(t/Tf) : f0 + t/Tf*(f1-f0)
    sin(2π*f*t)
end
