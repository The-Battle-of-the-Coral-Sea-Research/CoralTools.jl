module CoralTools

using RecipesBase
using Geodesics
using CoralData
using CoralData: SectorSearchPlan, SpatTempPos, SpatPos
using Dates

export forward_deg, inverse_deg, get_pos, interpolate_stp_vec

include("defs.jl")
include("geodesics_utils.jl")
include("interpolate_utils.jl")
include("recipes.jl")

end # module
