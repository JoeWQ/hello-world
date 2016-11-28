/*
  *@aim:�������㷨ʵ��
  *@date:2015-6-11 18:59
  */
 #include"simplex.h"
 #include<assert.h>
 #include<stdio.h>
 //��׼��ת��Ϊ�ɳ���
 //ע��,�������ܻ��޸�src������
  static      bool            simplex_normal_switch_relax(CSimplex     *src,CSimplex   *dst);
  //ע��,�������ܻ��޸�simplex������,�����ʼ����Լ�������з���CSimplexTypeInvalide
  static      CSimplexType            init_simplex(CSimplex   *simple);
 //���캯������������
   CSimplex::CSimplex()
  {
             this->basicVariableIndexes=NULL;
             this->nonbasicVariableIndexes=NULL;
             this->relaxConstants=NULL;
             this->relaxExpressRestrict=NULL;
             this->objectFunc=NULL;
             this->objectConstant=0.0f;
   }
   CSimplex::CSimplex(int     basicVariableSize,int    nonVariableSize)
  {
             this->basicVariableIndexes=new    CArray<int>(basicVariableSize);
             this->nonbasicVariableIndexes=new   CArray<int>(nonVariableSize);
             this->objectFunc=new    CArray<float>(basicVariableSize+nonVariableSize);
             this->relaxExpressRestrict=new    CArray2D<float>(basicVariableSize+nonVariableSize,basicVariableSize+nonVariableSize);
             this->relaxConstants=new    CArray<float>(basicVariableSize+nonVariableSize);
             this->objectConstant=0.0f;
   }
   CSimplex::~CSimplex()
  {
             delete       basicVariableIndexes;
             delete       nonbasicVariableIndexes;
             delete       relaxConstants;
             delete       relaxExpressRestrict;
             delete       objectFunc;
             objectConstant=0.0f;
   }
//��Ԫ�Ľ���,������֮��Ĵ���
//��Ԫ�Ľ���,������֮��Ĵ���
//@param:swap_out�������Ļ�������������,
//@param:swap_in������ķǻ�����������
//������swap_in,swap_out����ݽ���,���������ͷǻ��������Ļ���
//@request:relaxExpressRestrict->get(swap_out,swap_in)>0
  static         void            swap_pivot(CSimplex        *simplex,int  swap_out,int  swap_in   )
 {
              float              factor;
              float              relaxConstant;
              float              coef;
              int                 i,j,k;
//ѡ��Ŀ��Լ����,����Լ���еĳ�������
              factor=simplex->relaxExpressRestrict->get(swap_out,swap_in);
              relaxConstant=simplex->relaxConstants->get(swap_out);
//д���µ�λ��swap_in,�����ɳ�Լ���еĳ�����
              relaxConstant/=factor;
              const       float    swap_in_constant=relaxConstant;
              simplex->relaxConstants->set(swap_in,relaxConstant);
//����swap_in�е��ɳ�Լ�����ʽ
//���µ��ɳ�Լ���м���swap_out�ǻ�������
              simplex->relaxExpressRestrict->set(swap_in,swap_out,1.0f/factor);
              for(i=0;i<simplex->nonbasicVariableIndexes->size;++i)
             {
                            j=simplex->nonbasicVariableIndexes->get(i);
//ȡ��Դ�ɳ�Լ���е�ϵ��
                            relaxConstant=simplex->relaxExpressRestrict->get(swap_out,j);
                            relaxConstant/=factor;
//д���µ��ɳ�Լ������
                            simplex->relaxExpressRestrict->set(swap_in,j,relaxConstant);
              }
//����ʣ����ɳ�Լ����
               for(i=0;i<simplex->basicVariableIndexes->size;++i)
              {
//���ȼ����µ�swap_out�ǻ�������Լ��
                           k=simplex->basicVariableIndexes->get(i);
                           if(  k  !=  swap_out   )
                          {
                                      relaxConstant=simplex->relaxConstants->get(k);
                                      relaxConstant-=simplex->relaxExpressRestrict->get(k,swap_in)*swap_in_constant;
                                      simplex->relaxConstants->array[k]=relaxConstant;
//����ʣ����ɳ�Լ���зǻ���������ϵ��
                                      coef=simplex->relaxExpressRestrict->get(k,swap_in);
                                      for(j=0;j<simplex->nonbasicVariableIndexes->size;++j)
                                     {
                                                 int     column=simplex->nonbasicVariableIndexes->get(j);
                                                 if( column !=  swap_in )//�޳����������
                                                {
//����ϵ��
                                                           relaxConstant=simplex->relaxExpressRestrict->get(k,column);
                                                           relaxConstant-=simplex->relaxExpressRestrict->get(swap_in,column)*coef;
                                                           simplex->relaxExpressRestrict->set(k,column,relaxConstant);
                                                 }
                                      }
//�����ϻ�������swap_out��ϵ��Լ��
                                      relaxConstant=-coef/factor;
                                      simplex->relaxExpressRestrict->set(k,swap_out,relaxConstant);
                           }
               }
//����Ŀ�꺯��
//1:������
               simplex->objectConstant+=simplex->objectFunc->get(swap_in)*swap_in_constant;
//����ʣ���Ŀ�꺯���еĳ�����
              relaxConstant=simplex->objectFunc->get(swap_in);
              simplex->objectFunc->array[swap_out]=-relaxConstant*1.0f/factor;
              for(i=0;i<simplex->nonbasicVariableIndexes->size;++i)
             {
                               k=simplex->nonbasicVariableIndexes->get(i);
                               if( k !=swap_in )
                              {
                                             coef=simplex->objectFunc->get(k);
                                             coef-=simplex->relaxExpressRestrict->get(swap_in,k)*relaxConstant;
                                             simplex->objectFunc->set(k,coef);
                               }
              }
//��swap_in�ӷǻ�������������ɾ��,swap_out�ӻ�������������ɾ��
//���������໥��ӵ��Է�ԭ�����ڵļ�����
            for(i=0;i<simplex->nonbasicVariableIndexes->size;++i )
           {
                            if(  simplex->nonbasicVariableIndexes->get(i)  == swap_in )
                           {
                                             simplex->nonbasicVariableIndexes->set(i,swap_out);
                                             break;
                            }
            }
            for(i=0;i<simplex->basicVariableIndexes->size;++i)
           {
                             if(simplex->basicVariableIndexes->get(i) == swap_out)
                            {
                                          simplex->basicVariableIndexes->set(i,swap_in);
                                          break;
                             }
            }
  }
//���,Ŀ�꺯�����Ƿ���һ��ϵ������0,����д���0���������ĵ�ϵ��,��idx�з�����������
   static           bool            isCoefficientPositive(CSimplex   *simplex,int     *idx)
  {
//ע�������Ѱַ��ʽ
             int           udx=-1;
             float        factor=0.0f;
             for(int  i=0;i<simplex->nonbasicVariableIndexes->size;++i)
            {
                         int        k=simplex->nonbasicVariableIndexes->array[i];
                         if(simplex->objectFunc->array[k] >factor )
                        {
                                       factor=simplex->objectFunc->array[k];
                                       udx=k;
                         }
             }
             *idx=udx;
             return         udx != -1;
    }
//�������㷨,������гɹ�������result�з�����������ս��
   CSimplexType          simplex_algorithm(CSimplex         *simplex,float     *result)
  {
                 const           float         einf=1e8;
                 float             factor,relax;
                 int                i,j,k;
                 int                idx;
//���ȳ�ʼ������ı�׼��
                 if(  init_simplex(simplex) == CSimplexTypeInvalide )
                            return    CSimplexTypeInvalide;
//                 printf("init_simplex over -----------------\n");
                 while(  isCoefficientPositive(simplex,&idx)  )
                {
//�����е��ɳ�Լ����,ѡ��һ������յ�һ��
                                printf("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n");
                                factor=einf;
                                j=-1;
                                for(i=0;i<simplex->basicVariableIndexes->size;++i)
                               {
                                             k=simplex->basicVariableIndexes->get(i);
                                             relax=simplex->relaxExpressRestrict->get(k,idx);
                                             if(  relax>0.0f )
                                            {
                                                          float            value=simplex->relaxConstants->get(k)/relax;
                                                          if( value<factor )
                                                         {
                                                                           factor=value;
                                                                           j=k;
                                                          }
                                             }
                                }
//���û���ҵ�ʹ��factor!=einf�Ľ�,˵���˵��������޽��
                                if( j == -1)
                                           return       CSimplexTypeNoBound;
//ʣ�µĲ���,��������ǻ�����֮���ת��
                                 swap_pivot(simplex,j,idx);
                 }
                 *result=simplex->objectConstant;
//ע��,��ʣ�µĽ��벽���У�������simplex->basicVariableIndexes�еĻ��������趨Ϊ0�Ϳ���������Ľ�
                 return     CSimplexTypeOK;
   }
//��׼��ת��Ϊ�ɳ���
//request:simplex�ĸ���һά���кͶ�ά���������Ҫ�����б���+�ɳ�Լ������Ŀ֮�ʹ�1,
//@request:���������������Խ��,����ʱ�쳣
   CSimplexType              init_simplex(CSimplex          *simplex)
  {
                 float               factor=1e8;
                 float               coef,value;
                 int                  i,j,k;
//��ⳣϵ��
                  j=-1;
                 for(i=0;i<simplex->basicVariableIndexes->size;++i)
                {
                                k=simplex->basicVariableIndexes->get(i);
                                coef=simplex->relaxConstants->get(k);
                                if( coef <factor)
                               {
                                                factor=k;
                                                j=k;
                                }
                 }
//���û�и��ĳ�ϵ��,��ʱ�Ϳ���ֱ�ӷ���
                 if(  factor>=0.0f)
                             return      CSimplexTypeOK;
//����,ִ�б任
//���½����µ����Թ滮���ݽṹ,��ʹ���µĽṹ���жϵ�ǰ�Ľṹ�Ƿ������Ž�,�����Ժ�ʵ��
//�����µķǻ�����(m+n-1),�趨Ŀ�꺯��Ϊmax=-X(m+n-1),���Ŀ�꺯��������ֵ��Ϊ0,�����Թ滮�ǲ����еĵ�
                 CSimplex       asimplex;
                 CSimplex       *other=&asimplex;
                 other->basicVariableIndexes=new    CArray<int>(simplex->basicVariableIndexes->size);
                 other->nonbasicVariableIndexes=new   CArray<int>(simplex->nonbasicVariableIndexes->size+1);
                 const int           size=other->basicVariableIndexes->size+other->nonbasicVariableIndexes->size;
                 other->relaxConstants=new   CArray<float>(size);
                 other->relaxExpressRestrict=new    CArray2D<float>(size,size);
                 other->objectFunc=new   CArray<float>(size);
//ʹ��Դ���ݶ������ɵ����ݽṹ���г�ʼ��
//Ŀ�꺯��
                 other->objectFunc->fillWith(0.0f);
                 other->objectFunc->array[size-1]=-1;
//������
                 other->basicVariableIndexes->copyWith(simplex->basicVariableIndexes);
//�ǻ�����
                 other->nonbasicVariableIndexes->copyWith(simplex->nonbasicVariableIndexes);
                 other->nonbasicVariableIndexes->array[i]=size-1;
//������
                 other->relaxConstants->copyWith(simplex->relaxConstants);
//����,��⵱ǰ�����Թ滮�Ƿ��п��н�
                 swap_pivot(other,j,size-1);
                 int                idx;
                 while( isCoefficientPositive(other,&idx)  )
                {
                              factor=1e8;
                              j=-1;
                              for(i=0;i<other->basicVariableIndexes->size;++i)
                             {
                                             k=other->basicVariableIndexes->array[i];
                                             coef=other->relaxExpressRestrict->get(k,idx);
                                             if(coef>0)
                                            {
                                                           value=other->relaxConstants->array[k]/coef;
                                                           if(value<factor)
                                                          {
                                                                         factor=coef;
                                                                         j=k;
                                                           }
                                             }
                               }
                               if( j == -1 )
                                        return         CSimplexTypeNoBound;
                               swap_pivot(other,j,idx);
                 }
//�������Ŀ��ֵ
                 if( other->objectConstant < 0.0f  )
                            return       CSimplexTypeInvalide;
//������size-1�޳���
                 simplex->objectFunc->copyWith(other->objectFunc,size-1);
                 simplex->objectConstant=other->objectConstant;
//�ӷǻ����������н�size-1�޳���
                for(j=0,i=0;i<size;++i  )
               {
                            if(  other->nonbasicVariableIndexes->array[i] != size-1  )
                                       simplex->nonbasicVariableIndexes->array[j++]=other->nonbasicVariableIndexes->array[i];
                }
//�ϸ��˵��size-1�����ڻ����������г���,
                for( j=0,i=0;i<size;++i )
               {
                            k=other->basicVariableIndexes->array[i];
                            if(  k != size-1 ) 
                                      simplex->basicVariableIndexes->array[j++]=k;
                }
//��άϵ��������
                for(i=0;i<size-1;++i)
               {
                             for(j=0;j<size-1;++j)
                            {
                                             factor=other->relaxExpressRestrict->get(i,j);
                                             simplex->relaxExpressRestrict->set(i,j,factor);
                             }
                }
//�ɳ�Լ���ĳ�ϵ��
                 simplex->relaxConstants->copyWith(other->relaxConstants);
                 return            CSimplexTypeOK;
   }
 //
    int               main(int       argc,char     *argv[])
   {
                 CSimplex            asimplex;
                 CSimplex            *simplex=&asimplex;
//ϵ������,ע�������ɳ���ϵ��
                 const                  int                       size=4;
                 float                    coefficient[4][4]={
                                                          {0,0,2,-1},{0,0,1,-4}
                                                };
//�ɳڱ��ʽ��ϵ������
                 float                    relaxConstants[5]={2,-4};
//Ŀ�꺯��
                 float                    objectFunc[5]={0,0,2,-1};
                 float                    objectConstant=0.0f;
//������������
                 int                       variableSize=2;
                 int                       basicVariable[2]={0,1};
//�ǻ�����������
                 int                       nonVariableSize=2;
                 int                       nonbasicVariable[3]={2,3};
//�������������ݽṹ
                 int                       i,j,k;
                 simplex->basicVariableIndexes=new    CArray<int>(variableSize);
                 simplex->nonbasicVariableIndexes=new    CArray<int>(nonVariableSize);
                 simplex->relaxConstants=new     CArray<float>(size);
                 simplex->relaxExpressRestrict=new    CArray2D<float>(size,size);
                 simplex->objectFunc=new     CArray<float>(size);
//ʹ�ó������������д�뵽���������ݽṹ��
                 for(i=0;i<simplex->basicVariableIndexes->size;++i)
                              simplex->basicVariableIndexes->array[i]=basicVariable[i];
                 for(i=0;i<simplex->nonbasicVariableIndexes->size;++i)
                              simplex->nonbasicVariableIndexes->array[i]=nonbasicVariable[i];
//������
                 for(i=0;i<simplex->relaxConstants->size;++i)
                              simplex->relaxConstants->array[i]=relaxConstants[i];
//ϵ������
                 for(i=0;i<simplex->relaxExpressRestrict->rowCount();++i)
                              for(j=0;j<simplex->relaxExpressRestrict->columnCount();++j)
                                                 simplex->relaxExpressRestrict->set(i,j,coefficient[i][j]);
//Ŀ�꺯��
                 for(i=0;i<simplex->objectFunc->size;++i)
                              simplex->objectFunc->array[i]=objectFunc[i];
                 simplex->objectConstant=objectConstant;
                 float         result;
//                 printf("begin--------------------\n");
                 if(  simplex_algorithm(simplex,&result) == CSimplexTypeOK )
                             printf("result  is %f  \n",result);
                 else
                             printf(" error    !\n");
                 return        0;
    }
    