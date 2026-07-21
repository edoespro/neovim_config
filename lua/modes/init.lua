local mgr = require("modes.manager")
require("modes.normal")

function get_mode()
return mgr.getM_mode().name
end
