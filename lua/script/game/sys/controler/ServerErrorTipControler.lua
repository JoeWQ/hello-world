local ServerErrorTipControler = {}

ServerErrorTipControler.error_tips = require("game.sys.data.ServerErrorTips")

function ServerErrorTipControler:checkShowTipByError(errorData)
	
	if errorData.lang then 
		if not table.find(Server.SPECIAL_ERRORCODE, tonumber(errorData.code)) then
			WindowControler:showTips(errorData.lang)
		end
		return
	end
	local error_code = errorData.code..''
	local tips = self.error_tips
	local data = tips[error_code] 
	local tip = GameConfig.getErrorLanguage("#error"..error_code)
	if tip and tip~="" and not string.find(tip, "#error") then
		WindowControler:showTips(tip)
	else
		if GameStatic.displayErrorBoard then
			WindowControler:showTips(string.format("ServerErrorCode: %s", error_code))
		end
	end
	return tip
end

return ServerErrorTipControler
