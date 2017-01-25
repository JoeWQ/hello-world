--  User: cwb
--  Date: 2015/5/22
--  提示弹窗


local Tips = class("Tips", UIBase)


----   txt_warn 文本显示信息

function Tips:startShow(info  )
    self._isShow = true
    local str
    if type(info) == "string" then
        str = info
    else
        str = info.text
    end

    self:pos()

    self:stopAllActions()

    self:opacity(0)

    self:runAction(
        act.sequence(
                act.fadeto(0.15, 255),
                act.delaytime(0.6),
                act.fadeto(0.3, 0),
                act.callfunc(c_func(self.hideComplete, self))
            )
    )

    -- Tips.super.startShow(self)

    --1秒以后隐藏
    -- self:delayCall(c_func(self.startHide,self), 1.5)

    if self.txt_1 then
        self.txt_1:setString(str)
    else
        self.rich_1:setString(str)
    end
    

end





function Tips:loadUIComplete()
	Tips.super.loadUIComplete(self)

end


function Tips:hideComplete( )
    self:visible(false)
end


function Tips:updateUI()
end




return Tips
