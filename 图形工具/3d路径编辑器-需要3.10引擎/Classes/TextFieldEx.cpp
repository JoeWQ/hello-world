//
//  TextFieldEx.cpp
//  BoneTest
//
//  Created by charlie on 2017/3/27.
//
//

#include "TextFieldEx.hpp"
#include <string>
#include <sstream>

using namespace cocos2d;

TextFieldEx::TextFieldEx() :
DEFAULT_MAX_SIZE(5),
DEFAULT_SIZE(Size(120, 40)),
__selected(false),
__content(0),
__contentChangeCallback([](){}),
__max(90)
{
    NORMAL = {
        
        Color4B(190, 190, 190, 255),
        Color4F(0.2, 0.2, 0.2, 0.9),
        Color4F(0.05, 0.05, 0.05, 0.9),
        Color4F(0.1, 0.1, 0.1, 0.9),
        
    };
    
    SELECTED = {
        
        Color4B(255, 255, 255, 255),
        Color4F(0.0, 0.2, 0.0, 0.9),
        Color4F(0.0, 0.05, 0.0, 0.9),
        Color4F(0.1, 0.1, 0.1, 0.9),
        
    };
}

TextFieldEx::~TextFieldEx()
{
    
}

TextFieldEx* TextFieldEx::create()
{
    TextFieldEx* pRet = new TextFieldEx();
    pRet->init();
    pRet->autorelease();
    return pRet;
}

bool TextFieldEx::init()
{
    Widget::init();
    
    __textField = ui::TextField::create();
    __textField->setPlaceHolder("0");
    __textField->setTouchAreaEnabled(true);
    __textField->setMaxLengthEnabled(true);
    __textField->setMaxLength(DEFAULT_MAX_SIZE);
    __textField->addEventListener(CC_CALLBACK_2(TextFieldEx::onTextFieldEvent, this));
    this->addChild(__textField, 1);
    
    __background = DrawNode::create();
    this->addChild(__background);
    
    __frame = DrawNode::create();
    __frame->setLineWidth(2);
    this->addChild(__frame);
    
    __title = Label::createWithSystemFont("", "", 20);
    this->addChild(__title);
    
    setSize(DEFAULT_SIZE);
    
    return true;
}

void TextFieldEx::onEnter()
{
    ui::Widget::onEnter();
    
    registerFocusEventListener();
    registerMouseEventListener();
}

void TextFieldEx::onExit()
{
    ui::Widget::onExit();
}

void TextFieldEx::setSize(cocos2d::Size size)
{
    __size = size;
    this->setContentSize(size);
    __textField->setPosition(size / 2);
    __textField->setTouchSize(size);
    __textField->setTouchSize(size);
    __title->setPosition(Size(size.width / 2, size.height + __title->getContentSize().height / 2 + 10));
    
    doColoring(NORMAL);
}

cocos2d::Size TextFieldEx::getSize()
{
    return __size;
}

void TextFieldEx::setContent(int content)
{
    applyInteger(content);
}

int TextFieldEx::getContent()
{
    return __content;
}

void TextFieldEx::setContentChangeCallback(std::function<void()> callback)
{
    __contentChangeCallback = callback;
}

void TextFieldEx::doColoring(COLOR_SCHEME color)
{
    __textField->setTextColor(color._textColor);
    __textField->setPlaceHolderColor(color._textColor);
    
    __background->clear();
    __background->drawSolidRect(Vec2(0, 0), DEFAULT_SIZE, color._backgroundColor);
    
    __frame->clear();
    __frame->drawRect(Vec2(-1, -1), DEFAULT_SIZE + Size(1, 1), color._frameColorDark);
    __frame->drawRect(Vec2(-2, -2), DEFAULT_SIZE + Size(2, 2), color._frameColorLight);
}

void TextFieldEx::registerFocusEventListener()
{
    EventListenerFocus* listener = EventListenerFocus::create();
    listener->onFocusChanged = CC_CALLBACK_2(TextFieldEx::onFocusChanged, this);
    this->getEventDispatcher()->addEventListenerWithSceneGraphPriority(listener, this);
}

void TextFieldEx::registerMouseEventListener()
{
    EventListenerMouse* listener = EventListenerMouse::create();
    listener->onMouseScroll = CC_CALLBACK_1(TextFieldEx::onMouseScroll, this);
    this->getEventDispatcher()->addEventListenerWithSceneGraphPriority(listener, this);
}


void TextFieldEx::onFocusChanged(cocos2d::ui::Widget* loseFocus, cocos2d::ui::Widget* getFocus)
{
    if(loseFocus == __textField)
    {
        onLoseFocus();
    }
    else if(getFocus == __textField)
    {
        onGetFocus();
    }
}

void TextFieldEx::onMouseScroll(cocos2d::EventMouse* event)
{
    Vec2 mouseLocation = event->getLocationInView();
    bool hit = this->hitTest(mouseLocation, Camera::getDefaultCamera(), nullptr);

    if(hit && __selected)
    {
        event->stopPropagation();
        
        applyInteger(__content + getStep(event->getScrollY()));
        triggerContentChangeEvent();
    }
}

void TextFieldEx::onGetFocus()
{
    __selected = true;
    doColoring(SELECTED);
}

void TextFieldEx::onLoseFocus()
{
    __selected = false;
    doColoring(NORMAL);
    applyInteger(__content);
    triggerContentChangeEvent();
}

void TextFieldEx::onTextFieldEvent(Ref* sender, cocos2d::ui::TextField::EventType event)
{
    if(event == ui::TextField::EventType::INSERT_TEXT or event == ui::TextField::EventType::DELETE_BACKWARD)
    {
        applyText(__textField->getString());
        triggerContentChangeEvent();
    }
}

bool TextFieldEx::s2i(std::string str, int& integer)
{
    std::stringstream converter;
    converter<<str;
    converter>>integer;
    
    return converter.fail();
}

bool TextFieldEx::i2s(int integer, std::string& str)
{
    std::stringstream converter;
    converter<<integer;
    converter>>str;
    
    return converter.fail();
}

bool TextFieldEx::onlyOperator(std::string str)
{
    if(str.size() == 1 and (str[0] == '-' or str[0] == '+'))
    {
        return true;
    }
    else
    {
        return false;
    }
}

bool TextFieldEx::containsIllegal(std::string str)
{
    for(int i = 1; i < str.size(); i++)
    {
        if(str[i] < 48 or str[i] > 57)
        {
            return true;
        }
    }
    
    return false;
}

bool TextFieldEx::empty(std::string str)
{
    return str.size() == 0;
}

void TextFieldEx::applyText(std::string str)
{
    int integer;
    
    if(s2i(str, integer))
    {
        applyInteger(integer);
        
        if(onlyOperator(str) or empty(str))
        {
            __textField->setString(str);
        }
    }
    else
    {
        applyInteger(integer);
    }
}

void TextFieldEx::applyInteger(int integer)
{
    __content = clampContent(integer);
    std::string str;
    i2s(__content, str);
    __textField->setString(str);
}

void TextFieldEx::triggerContentChangeEvent()
{
    __contentChangeCallback();
}

int TextFieldEx::clampContent(int content)
{
    if(content > 0)
    {
        int max = pow(10, DEFAULT_MAX_SIZE) - 1;
        max = max > __max ? __max : max;
        return content > max ? max : content;
    }
    else if(content < 0)
    {
        int max = pow(10, DEFAULT_MAX_SIZE - 1) - 1;
        max = max > __max ? __max : max;
        return abs(content) > max ? -max : content;
    }
    else
    {
        return 0;
    }
}

int TextFieldEx::getStep(float scrollY)
{
    if(fabs(scrollY) > 10)
    {
        return 10 * (fabs(scrollY) - 9) * scrollY / fabs(scrollY);
    }
    else
    {
        return 1 * scrollY / fabs(scrollY);
    }
}

void TextFieldEx::setTitle(std::string title)
{
    __title->setString(title);
    
    Size size = getContentSize();
    __title->setPosition(Size(size.width / 2, size.height + __title->getContentSize().height / 2 + 10));
}

void TextFieldEx::setMax(int max)
{
    __max = max > 0 ? max : __max;
}

std::string TextFieldEx::getTitle()
{
    return __title->getString();
}

void TextFieldEx::setTitleColor(cocos2d::Color3B color)
{
    __title->setColor(color);
}
