//
//  TextFieldEx.hpp
//  BoneTest
//
//  Created by charlie on 2017/3/27.
//
//

#ifndef TextFieldEx_hpp
#define TextFieldEx_hpp

#include "cocos2d.h"
#include "ui/CocosGUI.h"

class TextFieldEx : public cocos2d::ui::Widget
{
public:
    TextFieldEx();
    virtual ~TextFieldEx();
    
public:
    static TextFieldEx* create();
    virtual bool init();
    virtual void onEnter();
    virtual void onExit();
    
public:
    void setSize(cocos2d::Size size);
    cocos2d::Size getSize();
    void setContent(int content);
    int getContent();
    void setContentChangeCallback(std::function<void()> callback);
    void setTitle(std::string title);
    void setMax(int max);
    void setTitleColor(cocos2d::Color3B color);
    std::string getTitle();
    
private:
    struct COLOR_SCHEME
    {
        cocos2d::Color4B _textColor;
        cocos2d::Color4F _frameColorLight;
        cocos2d::Color4F _frameColorDark;
        cocos2d::Color4F _backgroundColor;
        
    }NORMAL, SELECTED;
    
private:
    void doColoring(COLOR_SCHEME color);
    void registerFocusEventListener();
    void registerMouseEventListener();
    void onFocusChanged(cocos2d::ui::Widget* loseFocus, cocos2d::ui::Widget* getFocus);
    void onMouseScroll(cocos2d::EventMouse* event);
    void onTextFieldEvent(Ref* sender, cocos2d::ui::TextField::EventType);
    void onGetFocus();
    void onLoseFocus();
    bool s2i(std::string str, int& integer);
    bool i2s(int integer, std::string& str);
    bool onlyOperator(std::string str);
    bool containsIllegal(std::string str);
    bool empty(std::string str);
    void applyText(std::string str);
    void applyInteger(int integer);
    void triggerContentChangeEvent();
    int clampContent(int content);
    int getStep(float scrollY);

private:
    const cocos2d::Size DEFAULT_SIZE;
    const int DEFAULT_MAX_SIZE;
    cocos2d::ui::TextField* __textField;
    cocos2d::DrawNode* __background;
    cocos2d::DrawNode* __frame;
    cocos2d::Label* __title;
    cocos2d::Size __size;
    int __content;
    bool __selected;
    int __max;
    std::function<void()> __contentChangeCallback;
};

#endif /* TextFieldEx_hpp */
