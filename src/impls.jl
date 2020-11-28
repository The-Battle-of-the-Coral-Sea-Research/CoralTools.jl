
# provide "implements" for some struct from CoralData.jl

SpatPos(rp::RelPos) = forward_deg(base, angle, dist)[1]
