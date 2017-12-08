--
-- Author: xd
-- Date: 2016-03-02 18:51:27
--管理音频和视频的 类
local AudioModel = AudioModel or {}

local STATUS_ON = FuncSetting.SWITCH_STATES.ON
local STATUS_OFF = FuncSetting.SWITCH_STATES.OFF

--初始化
function AudioModel:init()
	--读取本机缓存的音效开关
	self:initStatus()
	EventControler:addEventListener(SettingEvent.SETTINGEVENT_MUSIC_SETTING_CHANGE, self.onMusicStatusChange, self)
	EventControler:addEventListener(SettingEvent.SETTINGEVENT_SOUND_SETTING_CHANGE, self.onSoundStatusChange, self)

	self._currentMusic = nil;
	self._isCurrentMusicLoop = nil;

	self._currentSound = nil;
	self._isCurrentSoundLoop = nil;	
end

function AudioModel:initStatus()
	self._sound_status = LS:pub():get(StorageCode.setting_sound_st, FuncSetting.DEFAULT_SOUND_ST)
	self._music_status = LS:pub():get(StorageCode.setting_music_st, FuncSetting.DEFAULT_MUSIC_ST)
	self._battle_music_status = LS:pub():get(StorageCode.setting_battle_music_st, STATUS_OFF)
	self._battle_sound_status = LS:pub():get(StorageCode.setting_battle_sound_st, STATUS_OFF)
    cc.SimpleAudioEngine:getInstance():preloadEffect(GameConfig.getMusic("s_com_fixTip"));
end

--全局的音乐设置变化
function AudioModel:onMusicStatusChange(event)
	self._music_status = LS:pub():get(StorageCode.setting_music_st, STATUS_OFF)
	if self._music_status == STATUS_OFF then
		audio.pauseMusic()
	end
end

--全局的音效设置变化
function AudioModel:onSoundStatusChange(event)
	self._sound_status = LS:pub():get(StorageCode.setting_sound_st, STATUS_OFF)
end

function AudioModel:isSoundOn()
	local sound_st = LS:pub():get(StorageCode.setting_sound_st, FuncSetting.DEFAULT_SOUND_ST)
	return sound_st == STATUS_ON
end

function AudioModel:isMusicOn()
	local music_st = LS:pub():get(StorageCode.setting_music_st, FuncSetting.DEFAULT_MUSIC_ST)
	return music_st == STATUS_ON
end

function AudioModel:isBattleSoundOn()
	return self:isMusicOn() and self._battle_sound_status == STATUS_ON
end

function AudioModel:isBattleMusicOn()
	return self:isSoundOn() and self._battle_music_status == STATUS_ON
end

--战斗中的音效暂停
function AudioModel:battlePauseSound()
	self._battle_sound_status = STATUS_OFF
	LS:pub():set(StorageCode.setting_battle_sound_st, STATUS_OFF)
end

--战斗中的音效恢复
function AudioModel:battleResumeSound()
	self._battle_sound_status = STATUS_ON
	LS:pub():set(StorageCode.setting_battle_sound_st, STATUS_ON)
end


function AudioModel:playSound(key, isLoop)
	if not self:isSoundOn() then return end

	local musicFile = GameConfig.getMusic(key)
	--dev test
	local musicFileExist = cc.FileUtils:getInstance():isFileExist(musicFile)

	if musicFileExist == false then 
		echoWarn("sound is not exist. key is ".. tostring(key));
	end 

	if musicFile and musicFileExist then
		self._currentSound = key;
		self._isCurrentSoundLoop = isLoop;	
		audio.playSound(musicFile, isLoop)
	end
end


function AudioModel:playMusic(key, isLoop)
	if not self:isMusicOn() then return end

	local musicFile = GameConfig.getMusic(key)
	if musicFile then
		audio.playMusic(musicFile, isLoop)
		self._currentMusic = key;
		self._isCurrentMusicLoop = isLoop;
	end
end

--停止当前音乐
function AudioModel:stopMusic(  )
	audio:stopMusic()
end

function AudioModel:resumeMusic()
	audio.resumeMusic()
end

function AudioModel:getCurrentSound()
	return self._currentSound, self._isCurrentSoundLoop;
end

function AudioModel:getCurrentMusic()
	return self._currentMusic, self._isCurrentMusicLoop;
end


return AudioModel
