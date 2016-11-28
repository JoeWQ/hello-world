/*
  *@aim:���Թ滮,�������㷨ʵ��
  *@note:�����ʵ�ֱȳ����ʵ����ȣ���Ҫ����Ĵ洢�ռ�,������Ը�ǿ,����Ҫ�Ĵ������
  *@date:2015-6-11
  */
  #ifndef    __SIMPLEX_H__
  #define   __SIMPLEX_H__
  #include"CArray2D.h"
  #include"CArray.h"
//�������㷨����Ҫ�����ݽṹ
//@note:ʹ�õĹ���
/*
  *@1:�ɳ�Լ�����ʽ�е�k�������������±���k,�ǻ����������±�Ϊm+i,mΪ�����������������
  *@2:ϵ�����������(m+n,m+n),mΪ����������Ŀ,n�ǻ�����������Ŀ
  */
  struct        CSimplex
 {
//��¼��������������
             CArray<int>              *basicVariableIndexes;
//��¼�ǻ�������������
             CArray<int>              *nonbasicVariableIndexes;
//��¼ÿ���ɳ�Լ���еĳ���,�䳤�Ⱥ�nonbasicVariableIndexes+basicVariableIndexes���
             CArray<float>           *relaxConstants;
//�ɳ�Լ�����ʽ�ľ�������
             CArray2D<float>      *relaxExpressRestrict;
//Ŀ�꺯��,�����ݵĳ���ΪnonbasicVariableIndexes->size+bacsicVariableIndexes->size
//����Ŀ�꺯�������ֵ
             CArray<float>           *objectFunc;
//Ŀ�꺯���еĳ�����             
             float                            objectConstant;
//
             CSimplex();
             CSimplex(int     basicVariableSize,int    nonVariableSize);
             ~CSimplex();
  };
   enum      CSimplexType
  {
             CSimplexTypeInvalide,//���������벻����
             CSimplexTypeNoBound,//�������㷨���õ��Ľ�����޽��
             CSimplexTypeOK,//�������㷨���ܵõ�һ�������Ľ��
   };
 //�������㷨ʵ��
 //@request:����ǰsimple�Ѿ����ɳ��͵�
 //@return:���������ö�������е�һ��,�������ɹ����򽫽��д�뵽result��
   CSimplexType           simplex_algorithm(CSimplex    *simplex,float   *result);
  #endif
  