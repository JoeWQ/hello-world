/*
  *@统一变量,注意,统一变量对象不能单独使用,必须内嵌到管理程序对象的GLProgramState对象中
  &2016-4-21
  */
#ifndef    __UNIFORM_H__
#define   __UNIFORM_H__
//统一变量的类型
  enum       UniformType
 {
             UniformTypeInt=1,//整数
             UniformTypeSampler=2,//采样器,只能接受整数值
             UniformTypeFloat=3,//单浮点数
             UniformTypeVec2=4,//二维浮点向量
             UniformTypeVec3=5,//三维浮点向量
             UniformTypeVec4=6,//四维浮点向量
             UniformTypeMat3=7,//3维矩阵
             UniformTypeMat4=8,//4维矩阵
             UniformTypeNum,
  };
//所有统一变量的祖先
  class        UniformVariable
 {
 private:
          int                        _variableLoc;//统一变量的位置
          UniformType       _variableType;//统一变量的类型
//禁止对象复制
private:
          UniformVariable(Uniformvariable &);
public:
          UniformVariable(int   loc,UniformType  type);
//后继类必须实现这四个函数,至于每个函数的有效性,取决于子类本身的性质
public:
          virtual       void         setUniformInt(int    *value,int  count);
          virtual       void         setUniformSampler(int  _textureId,int  unit,int   textureType);//设置纹理,以及纹理单元绑定
          virtual       void         setUniformFloat(float     *value,int    count);
          virtual       void         apply()=0;//将统一变量的值应用到着色器中
  };
//整数
  class       UniformInt:public  UniformVariable
 {
private:
           int             _value;
public:
           UniformInt(int     _vLoc);
           virtual        void         setUniformInt(int   *,int   count); 
           virtual         void        apply();
  };
//采样器
  class       UniformSampler:public    UniformVariable
 {
private:
            int             _textureId;//采样器对象GL_TEXTURE_2D,GL_TEXTURE_3D...
            int             _unit;//纹理单元
            int             _textureType;//纹理对象的类型
public:
            UniformSampler(int     _vLoc);
            virtual          void           setUniformSampler(int   _textureId,int    _unit,int  _textureType);
            virtual          void           apply();
  };
//单浮点统一变量
  class       UniformFloat:public  UniformVariable
 {
private:
           float          _value;
public:
           UniformFloat(int   _vLoc);
           virtual        void         setUniformFloat(float      *value,int   count);
           virtual        void         apply();
  };
//二维浮点向量
  class     UniformVec2:public  UniformVariable
 {
private:
           float          _value[2];
public:
           UniformVec2(int   _vLoc);
           virtual      void         setUniformFloat(float   *value,int   count);
           virtual      void         apply();
  };
//三维浮点向量
  class      UniformVec3:public UniformVariable
 {
private:
           float          _value[3];
public:
           UniformVec3(int   _vLoc);
           virtual        void       setUniformFloat(float     *value,int   count);
           virtual        void         apply();
  };
//四维浮点向量
   class      UniformVec4:public  UniformVariable
 {
private:
           float          _value[4];
public:
           UniformVec4(int   _vLoc);
           virtual        void      setUniformFloat(float    *value,int    count);
           virtual        void         apply();
  };
//4维矩阵,待实现
  class       UniformMat4
 {
private:
//            Mat4            _value;
public:
            UniformMat4(int   _vLoc);
            virtual        void        setUniformFloat(float     *value,int  count);
            virtual        void         apply();
  };
#endif