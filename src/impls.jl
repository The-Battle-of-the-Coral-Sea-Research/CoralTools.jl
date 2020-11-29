
# provide "implements" for some struct from CoralData.jl

SpatPos(rp::RelPos{SpatPos}) = forward_deg(rp.base, rp.angle, rp.dist)[1]
function SpatPos(rp::RelPos{String}, stpi_vec_map, time_begin)
    return forward_deg(get_pos(stpi_vec_map[rp.base], time_begin), rp.angle, rp.dist)[1]
end
SpatPos(rp::RelPos{SpatPos}, stpi_vec_map, time_begin) = SpatPos(rp)
