


"""
    reset_speed(stpi_vec::Vector{SpatTempPosInt}, speed::Real)

Ignore old timestamp and assign some new timestamps according to assumed uniform speed.
Speed: km/h
"""
function reset_speed(stpi_vec::Vector{SpatTempPosInt}, speed::Real)
    distance_vec = [stpi.d for stpi in stpi_vec]
    distance_sum = sum(distance_vec)
    p_vec = cumsum(distance_vec ./ distance_sum)
    elapsed_ms_value = distance_sum / speed * 3600_000
    elapsed_time_vec = Millisecond.(round.(elapsed_ms_value .* p_vec)) # What a pain, Julia
    time_begin = stpi_vec[1].time
    return [SpatTempPosInt(stpi.longitude, stpi.latitude, time_begin + dt, stpi.d)
            for (stpi, dt) in zip(stpi_vec, elapsed_time_vec)]
end
