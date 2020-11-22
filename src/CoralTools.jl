module CoralTools

using RecipesBase
using Geodesics
using CoralData
using CoralData: SectorSearchPlan, SpatTempPos, SpatPos,
    Action, MoveTo, TurnAngleTo, TurnAngle, MoveForward,
    mi, p, pp,
    normal_single_line_search, get_deg_vec
using Dates
using Distances
# using Plots

export forward_deg, inverse_deg, get_pos, interpolate_stp_vec, DateTime

include("defs.jl")
include("geodesics_utils.jl")
include("interpolate_utils.jl")
include("actions.jl")
include("recipes.jl")


end # module
