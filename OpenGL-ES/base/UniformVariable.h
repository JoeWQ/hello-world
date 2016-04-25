/*
  *@ͳһ����,ע��,ͳһ���������ܵ���ʹ��,������Ƕ�������������GLProgramState������
  &2016-4-21
  */
#ifndef    __UNIFORM_H__
#define   __UNIFORM_H__
//ͳһ����������
  enum       UniformType
 {
             UniformTypeInt=1,//����
             UniformTypeSampler=2,//������,ֻ�ܽ�������ֵ
             UniformTypeFloat=3,//��������
             UniformTypeVec2=4,//��ά��������
             UniformTypeVec3=5,//��ά��������
             UniformTypeVec4=6,//��ά��������
             UniformTypeMat3=7,//3ά����
             UniformTypeMat4=8,//4ά����
             UniformTypeNum,
  };
//����ͳһ����������
  class        UniformVariable
 {
 private:
          int                        _variableLoc;//ͳһ������λ��
          UniformType       _variableType;//ͳһ����������
//��ֹ������
private:
          UniformVariable(Uniformvariable &);
public:
          UniformVariable(int   loc,UniformType  type);
//��������ʵ�����ĸ�����,����ÿ����������Ч��,ȡ�������౾�������
public:
          virtual       void         setUniformInt(int    *value,int  count);
          virtual       void         setUniformSampler(int  _textureId,int  unit,int   textureType);//��������,�Լ�����Ԫ��
          virtual       void         setUniformFloat(float     *value,int    count);
          virtual       void         apply()=0;//��ͳһ������ֵӦ�õ���ɫ����
  };
//����
  class       UniformInt:public  UniformVariable
 {
private:
           int             _value;
public:
           UniformInt(int     _vLoc);
           virtual        void         setUniformInt(int   *,int   count); 
           virtual         void        apply();
  };
//������
  class       UniformSampler:public    UniformVariable
 {
private:
            int             _textureId;//����������GL_TEXTURE_2D,GL_TEXTURE_3D...
            int             _unit;//����Ԫ
            int             _textureType;//������������
public:
            UniformSampler(int     _vLoc);
            virtual          void           setUniformSampler(int   _textureId,int    _unit,int  _textureType);
            virtual          void           apply();
  };
//������ͳһ����
  class       UniformFloat:public  UniformVariable
 {
private:
           float          _value;
public:
           UniformFloat(int   _vLoc);
           virtual        void         setUniformFloat(float      *value,int   count);
           virtual        void         apply();
  };
//��ά��������
  class     UniformVec2:public  UniformVariable
 {
private:
           float          _value[2];
public:
           UniformVec2(int   _vLoc);
           virtual      void         setUniformFloat(float   *value,int   count);
           virtual      void         apply();
  };
//��ά��������
  class      UniformVec3:public UniformVariable
 {
private:
           float          _value[3];
public:
           UniformVec3(int   _vLoc);
           virtual        void       setUniformFloat(float     *value,int   count);
           virtual        void         apply();
  };
//��ά��������
   class      UniformVec4:public  UniformVariable
 {
private:
           float          _value[4];
public:
           UniformVec4(int   _vLoc);
           virtual        void      setUniformFloat(float    *value,int    count);
           virtual        void         apply();
  };
//4ά����,��ʵ��
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