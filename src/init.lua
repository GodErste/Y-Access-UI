local Access = require("./Access")
local Progress = require("./Progress")

return {
	Version = "1.0.0",
	CreateAccess = Access.new,
	CreateProgress = Progress.new,
}
