--
-- User: ZhangYanGuang
-- Date: 15-5-14
-- 音效及背景音乐播放
--

EffectEngine = class("EffectEngine");

local effectEngine = EffectEngine:new();

function EffectEngine.getInstance()
    return effectEngine;
end

--播放音效
function EffectEngine:playSound(soundId,isLoop)
    local soundFile = GameConfig.getMusic(soundId);
    if soundFile ~= nil then
        audio.playSound(soundFile, isLoop);
    end
end

--播放背景音乐
function EffectEngine:playMusic(musicId,isLoop)
	local musicFile = GameConfig:getMusic(musicId);
    if musicFile ~= nil then
        audio.playMusic(musicFile, isLoop);
    end
end

--暂停背景音乐
function EffectEngine:pauseMusic()
	if audio.isBackgroundMusicPlaying() then
		audio.pauseMusic();
	end
end
