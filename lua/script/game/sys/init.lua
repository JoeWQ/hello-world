local packageName = "game.sys."
require(packageName.."GameVars")
if not DEBUG_SERVICES  then
	require(packageName.."view.init")
	require(packageName.."controler.init")
	require(packageName.."service.init")
end
