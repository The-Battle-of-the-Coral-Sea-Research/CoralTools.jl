
#=
@recipe function f(fleet_trajectory_map::Dict{String, Vector{SpatTempPos}})
    for (fleet_name, stp_vec) in fleet_trajectory_map
        @series begin
            longitude = map(p -> p.longitude, stp_vec)
            latitude = map(p -> p.latitude, stp_vec)
            label --> fleet_name
            (longitude, latitude)
        end
    end
end
=#

function get_deg_vec(deg_start, deg_end, length; search_lines)
    if deg_end < deg_start
        deg_end = deg_end + 360
    end
    if !search_lines
        return range(deg_start, deg_end, length=length) .% 360
    else
        diff = abs(deg_end - deg_start) / (length+1) / 2
        return (range(deg_start, deg_end, length=length+1)[1:end-1] .+ diff) .% 360
    end
end

function make_sector_search_lines_geo(base_long, base_lat, deg_start, deg_end, radius, num;
            search_lines, color=:yellow)
    deg_vec = get_deg_vec(deg_start, deg_end, num; search_lines)
    long_lat_vec = forward_deg.(base_long, base_lat, deg_vec, radius)
	long_vec = map(long_lat->long_lat[1], long_lat_vec)
    lat_vec = map(long_lat->long_lat[2], long_lat_vec)
    return long_vec, lat_vec
end

@recipe function f(plan::Dict{String, SectorSearchPlan}; color=:yellow, particles=100)
    for (name, ssp) in plan
        @series begin
            base_long = ssp.base.longitude
            base_lat = ssp.base.latitude
            long_vec, lat_vec = make_sector_search_lines_geo(base_long, base_lat, 
                ssp.bearing[1], ssp.bearing[2], ssp.distance, particles, search_lines=false) # num=2, search_lines=false will select min, max directions
            seriestype  -->  :shape
            seriesalpha --> 0.25
            seriescolor --> color
            [base_long; long_vec], [base_lat; lat_vec]
        end
    end
end
