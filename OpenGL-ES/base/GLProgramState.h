/*
  *@aim: 统一变量容器
  *2016-4-23
  */
#ifndef    __GLPROGRAM_STATE_H__
#define   __GLPROGRAM_STATE_H__
#include<map>
#include<string>
#include "UniformVariable.h"
#include "GLProgram.h"
 class    GLProgramState:public    GLObject
{
private:
         GLProgram                                                         *_glProgram;
         std::map<std::string,UniformVariable *>        _uniformVariables;
private:
         GLProgramState(GLProgramState &);
          GLProgramState(GLProgram   *);
          bool             initWithProgram(GLProgram   *);
public:
         static         GLProgramState       *createWithProgram(GLProgram  *);
         ~GLProgramState();
//设置统一变量的值,如过没有找到这个统一变量,程序可能会死掉
         void            setUniformFloat(const char  *,float *,int  count);
         void            setUniformInt(const char *,int  *,int  count);
//使用
         void            apply();
 };
#endif