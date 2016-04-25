/*
  *@aim:统一变量操作
  &2016-4-23
  */
#ifdef __APPLE__
      #include <OpenGLES/ES3/gl.h>
#else
     #include <GLES3/gl3.h>
#endif
#include"GLProgramState.h"
#include<stdio.h>
  GLProgramState::GLProgramState()
 {
             _glProgram=NULL;
  }
//
  GLProgramState::~GLProgramState()
 {
             _glProgram->release();
             std::map<std::string,UniformVariable *>::iterator    it=_uniformVariables.begin();
             for(   ;it != _uniformVariables.end(); ++it)
            {
                           UniformVariable          *_variable=it->second;
                           delete           _variable;
                           it->second=NULL;
             }
  }
//
   bool         GLProgramState::initWithProgram(GLProgram    *glProgram)
  {
               _glProgram=glProgram;
               glProgram->retain();
//获取整个着色器的统一变量
               int             object=glProgram->getObject();
               char          *_buffer=NULL;
               int              _bufferSize=0;
               int              _uniformNum=0;
//获取最大统一变量的字符串长度
               glGetProgramiv(object,GL_ACTIVE_UNIFORM_MAX_LENGTH,&_bufferSize);
               glGetProgramiv(object,GL_ACTIVE_UNIFORMS,&_uniformNum);
               _buffer=new    char[_bufferSize+2];
//创建统一变量
               for(int   _index=0;_index<_uniformNum;++_index)
              {
                             int      _length=0;
                             int      _size=0;
                             int      _type=0;
                             glGetActiveUniform(object,_index,_bufferSize+1,&_length,&_size,&_type,_buffer);
                             _buffer[_length]='\0';
                             int          _vLoc=glgetUniformLocation(object,_buffer);
                             UniformVariable         *_variable=NULL;
                             if(_type==GL_INT)
                                            _variable=new     UniformInt(_vLoc,UniformTypeInt);
                             else if(_type== GL_SAMPLER_2D || _type==GL_SAMPLER_3D || _type==GL_SAMPLER_CUBE || _type==GL_SAMPLER_2D_SHADOW)
                                             _variable=new    UniformSampler(_vLoc,UniformSampler);
                             else if(_type == GL_FLOAT)
                                            _variable=new     UniformFloat(_vLoc,UniformTypeFloat);                              
                             else if(_type==GL_FLOAT_VEC2)
                                            _variable=new     UniformVec2(_vLoc,UniformTypeVec2);
                             else if(_type ==GL_FLOAT_VEC3)
                                            _variable=new      UniformVec3(_vLoc,UniformTypeVec3);
                             else if(_type == GL_FLOAT_VEC4)
                                            _variable=new      UniformVec4(_vLoc,UniformTypeVec4);
                             if( _variable)
                                        _uniformVariables[std::string(_buffer)]=_variable;
               }
   }
//
    GLProgramState              *GLProgramState::createWithProgram(GLprogram      *glProgram)
  {
                    GLProgramState          *_glState=new         GLProgramState();
                    _glState->initWithProgram(glProgram);
                    
                    return   _glState;
   }
//设置统一变量值
   void          GLProgramState::setUniformFloat(const char *name,float  *value,int  count)
  {
                   UniformVariable       *_variable=_uniformVariables[name];
                   if( _variable )
                                 _variable->setUniformFloat(value,count);
                   else
                  {
                                 printf("uniform variable '%s'  do not find.",name);
                                 assert(0);
                   }
   }
//
   void          GLProgramState::setUniformInt(const char *name,int  *value,int  count)
  {
                   UniformVariable       *_variable=_uniformVariables[name];
                   if(_variable )
                               _variable->setUniformInt(value,count);
                   else
                  {
                                 printf("uniform variable '%s'  do not find.",name);
                                 assert(0);
                   }
   }
//
   void          GLProgramState::apply()
  {
                  std::map<std::string,UniformVariable *>::iterator   it=_uniformVariables.begin();
                  for(   ;it != _uniformVariables.end(); ++it)
                                  it->second->apply();
   }