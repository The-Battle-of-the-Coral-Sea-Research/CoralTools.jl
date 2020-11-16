
function forward_deg_m(lon_deg, lat_deg, az_deg, dist)
    lon, lat, az = deg2rad(lon_deg), deg2rad(lat_deg), deg2rad(az_deg)
    lon1_lat1_backazimuth = Geodesics.forward(lon, lat, az, dist, Geodesics.EARTH_R_MAJOR_WGS84, Geodesics.F_WGS84)
    return rad2deg.(lon1_lat1_backazimuth)
end

function inverse_deg_m(lon1_deg, lat1_deg, lon2_deg, lat2_deg)
    lon1, lat1, lon2, lat2 = deg2rad.((lon1_deg, lat1_deg, lon2_deg, lat2_deg))
    dist, az, baz = Geodesics.inverse(lon1, lat1, lon2, lat2, Geodesics.EARTH_R_MAJOR_WGS84, Geodesics.F_WGS84)
    dist, rad2deg(az), rad2deg(baz)
end

# convert m to km

function forward_deg(lon_deg, lat_deg, az_deg, dist)
    return forward_deg_m(lon_deg, lat_deg, az_deg, dist * 1000)
end

function inverse_deg(lon1_deg, lat1_deg, lon2_deg, lat2_deg)
    dist, deg1, deg2 = inverse_deg_m(lon1_deg, lat1_deg, lon2_deg, lat2_deg)
    return dist / 1000, deg1, deg2
end
