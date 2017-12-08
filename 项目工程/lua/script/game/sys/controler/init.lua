local packageName = "game.sys.controler."
require(packageName .. "EventControler")
BattleControler = require(packageName.."BattleControler")
LoginControler = require(packageName.."LoginControler")
if DEBUG_SERVICES  then
	return
end

LogsControler = require(packageName.."LogsControler")
WindowControler = require(packageName.."WindowControler")
VerControler = require(packageName.."VerControler")
NotifyControler = require(packageName.."NotifyControler")
TimeControler = require(packageName.."TimeControler")
CombineControl = require(packageName.."CombineControl")
PlotDialogControl = require(packageName.."PlotDialogControl")
ServerErrorTipControler = require(packageName..'ServerErrorTipControler')
VersionControler = require(packageName.."VersionControler")
ClientActionControler = require(packageName.."ClientActionControler")
FriendViewControler = require(packageName.."FriendViewControler");
BattleLoadingControler = require(packageName.."BattleLoadingControler");