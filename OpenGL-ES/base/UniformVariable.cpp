/*
  *统一变量对象
  &2016-4-21
  */
#include"Uniform.h"
#include<assert.h>
#include<stdio.h>
#ifdef __APPLE__
      #include <OpenGLES/ES3/gl.h>
#else
     #include <GLES3/gl3.h>
#endif
  UniformVariable::UniformVariable(int    variableLoc,UniformType   type)
 {
              _variableLoc=variableLoc;
              _variableType=type;
  }
//虚函数禁用
  void             UniformVariable::setUniformInt(int  *value,int  count)
 {
             printf("Unsupported  function 'setUniformInt' in class %s\n",typeid(this).name());
             assert(0);
  }
 //浮点函数禁用,避免以后需要在各个类中实现
   void           UniformVariable::setUniformFloat(float    *value,int   count)
  {
            printf("Unsupported function  'setUniformFloat' in class %s\n",typeid(this).name());
            assert(0);
   }
//禁止采样器对象调用
   void           UniformVariable::setUniformSampler(int      _textureId,int   unit,int  textureType)
  {
            printf("Unsupported function 'setUniformSampler' in class %s\n",typeid(this).name());
            assert(0);
   }
//------------------------------整数-------------------------------------------------------
   UniformInt::UniformInt(int     _vLoc):UniformVariable(_vLoc,UniformTypeInt)
  {
              _value=0;
   }
//设置整数
    void       UniformInt::setUniformInt(int   *value,int   count)
   {
              assert(count==1);
              _value=*value;
    }
//应用
    void        UniformInt::apply()
   {
              glUniform1i(_variableLoc,_value);
    }
 //-------------------------------单浮点-----------------------------------------------
    UniformFloat::UniformFloat(int   _vLoc):UniformVariable(_vLoc,UniformTypeFloat)
   {
                _value=0.0f;
    }
    void           UniformFloat::setUniformFloat(float    *value,int  count)
  {
                assert(count==1);
                _value=value;
   }
   void            UniformFloat::apply()
  {
                glUniform1f(_variableLoc,_value);
   }
//-------------------------------------采样器对象-----------------------------------
    UniformSampler::UniformSampler(int    _vLoc):UniformVariable(_vLoc,UniformTypeSampler)
  {
                _sampler=0;
                _unit=0;
   }
//设置采样器对象
   void             UniformSampler::setUniformSampler(int    textureId,int  unit,int   textureType)
  {
//                 assert(textureType==GL_TEXTURE_2D || textureType==GL_TEXTURE_3D || textureType==GL_SAMPLER_CUBE || textureType==GL_SAMPLER_2D_SHADOW);
                 assert(unit>=0 && unit<=8);
                 assert(sampler>0);
                 _textureId=textureId;
                 _unit=unit;
                 _textureType=textureType;
   }
   void           UniformSampler::apply()
  {
                 glActiveTexture(GL_TEXTURE0+_unit);
                 glBindTexture(_textureType,_textureId);
                 glUniform1i(_variableLoc,_unit);
   }
//----------------------------------------------------二维向量------------------
   UniformVec2::UniformVec2(int     _vLoc):UniformVariable(_vLoc,UniformTypeVec2)
  {
                 _value[0]=0.0f;
                 _value[1]=0.0f;
   }
//
    void      UniformVec2::setUniformFloat(float   *value,int   count)
   {
                 assert(count==2);
                 _value[0]=*value;
                 _value[1]=*(value+1);
    }
 //
    void         UniformVec2::apply()
    {
                 glUniform2f(_variableLoc,_value[0],_value[1]);
     }
//------------------------------------------------三维向量---------------------------------------
     UniformVec3:UniformVec3(int    _vLoc):UniformVariable(_vLoc,UniformTypeVec3)
    {
                 _value[0]=0.0f;
                 _value[1]=0.0f;
                 _value[2]=0.0f;
     }
 //
     void          UniformVec3::setUniformFloat(float   *value,int  count)
    {
                  assert(count==3);
                  _value[0]=*value;
                  _value[1]=*(value+1);
                  _value[2]=*(value+2);
     }
     void           UniformVec3::apply()
   {
                 glUniform3fv(_variableLoc,1,_value);
    }
//--------------------------------------------四维向量-----------------------------
    UniformVec4::UniformVec4(int    _vLoc):UniformVariable(_vLoc,UniformTypeVevc4)
   {
                 _value[0]=0.0f;
                 _value[1]=0.0f;
                 _value[2]=0.0f;
                 _value[3]=0.0f;
    }
    void           UniformVec4::setUniformFloat(float   *value,int  count)
   {
                   assert(count==4);
                   _value[0]=value[0];
                   _value[1]=value[1];
                   _value[2]=value[2];
                   _value[3]=value[3];
    }
    void            UniformVec4::apply()
  {
                  glUniform4fv(_variableLoc,1,_value);
   }
//---------------------------------四维矩阵------------------
#ifdef    __MATRIX__ENABLE__
   UniformMat4::UniformMat4(int         _vLoc):UniformVariable(_vLoc,UniformTypeMta4)
  {
//设置成单位矩阵
                  for(int      i=0;i<4;++i)
                           for(int  k=0;k<4;++k)
                                        _value[i][k]=0.0f;
                  _value[0][0]=1.0f;
                  _value[1][1]=1.0f;
                  _value[2][2]=1.0f;
                  _value[3][3]=1.0f;
   }
   void              UniformMat4::setUniformFloat(float  *value,int   count)
  {
                  assert(count==16);                  
   }
#endif
     