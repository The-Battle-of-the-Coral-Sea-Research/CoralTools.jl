
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

@recipe function f(fleet_stpi_map::Dict{String, Vector{SpatTempPosInt}}, t::DateTime;
                   font=nothing)#, markersize=2) 
    # font ex: Plots.font("Sans", 4),
    # while it's better that Recipes provides an attribute to manipuate the annotation font size.
    longitude_vec = Float64[]
    latitude_vec = Float64[]
    fleet_name_vec = String[]
    for (fleet_name, stpi_vec) in fleet_stpi_map
        if !contains(stpi_vec, t)
            continue
        end
        pos = get_pos(stpi_vec, t)
        push!(longitude_vec, pos.longitude)
        push!(latitude_vec, pos.latitude)
        push!(fleet_name_vec, fleet_name)
    end
    @series begin
        seriestype --> :scatter
        label --> false
        series_annotations := (fleet_name_vec, font)
        longitude_vec, latitude_vec
    end
end

@recipe function f(fleet_stpi_vec_map::Dict{String, Vector{SpatTempPosInt}}, t1::DateTime, t2::DateTime;
                   font=nothing, step=Minute(10), full_only=false)
    t_vec_ref = t1:step:t2
    for (fleet_name, stpi_vec) in fleet_stpi_vec_map
        if full_only # consider only the path which covered the specified interval fully.
            if !contains(stpi_vec, t1, t2)
                continue
            end
            t_vec = t_vec_ref
        else
            if (t_vec_ref[end] < stpi_vec[1].time) | (stpi_vec[end].time < t_vec_ref[1])
                continue
            end
            t_vec = filter(t -> (t >= stpi_vec[1].time) & (t <= stpi_vec[end].time), t_vec_ref)
            if length(t_vec) == 0 # interval is too small
                continue
            end
        end
        # pos_vec = [get_pos(stpi_vec, t) for t in t1:step:t2]
        pos_vec = get_pos(stpi_vec, t_vec)
        longitude_vec = map(x->x.longitude, pos_vec)
        latitude_vec = map(x->x.latitude, pos_vec)
        @series begin
            label --> false
            longitude_vec, latitude_vec
        end
        @series begin
            seriestype --> :scatter
            label --> false
            # @show fleet_name longitude_vec latitude_vec
            longitude_vec, latitude_vec
        end
        @series begin
            seriestype --> :scatter
            seriesalpha --> 0
            series_annotations := ([fleet_name], font)
            [longitude_vec[end]], [latitude_vec[end]]
        end
    end
end

