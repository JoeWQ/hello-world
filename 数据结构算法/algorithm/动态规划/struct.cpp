/*
  *@aim:�Խṹ��ĳ�Ա��������,�������Ľ�����������г�Ա��˳����ʹ�õĳ�Ա��ռ�ݵ��ܵĿռ���С
  *@date:2015-11-7 10:49:34
  *@author:�ҽ���
  *@idea:��̬�滮
  */
  #include<stdio.h>
  #include"CArray2D.h"
//�ṹ�彨ģ
  struct         Member
 {
//�ṹ���Ա�ĳߴ�
             int                      width;
//��Ա�Ķ�������
             int                      alignWidth;
//�ṹ���Ա������
//             std::string          name;
  };
//�ṹ��ĳ�Ա
//��Ա����Ŀ,ע���Ա����Ч������1��ʼ
  void         struct_member_total_size(struct    Member     *_mem,int     size)
 {
//��¼��Աi,j��ռ�ݵĿռ�
             int                                   i,j,k;
             int                                   _offset;
             int                                   _width;
             int                                   _index;
             struct             Member   mem;
//             const             int            *y=new    int[size+2];
//��ʼ��,��������˵����д����
//             y[0]=0;
//             y[1]=_mem[1].width;
             _mem->width=0;
             _mem->alignWidth=4;
//�Ӵ����Աj��ʼ,��Ա0���ÿ���,��Ϊǰ���Ѿ�û�г�Ա��
             for( j=2 ; j<size; ++j )
            {
//��Ա_mem[d]�����Ŵ�����i��ʼ���ν��г��Բ��벢�Ƚ��������Ĵ���
                          _width=0x7FFFFFFF;
                          _index=0;
                          for(i=1;i<=j  ;++i  )//
                         {
                                         _offset=0;
                                         for( k=0;k<i;++k)
                                       {
                                                         if(_offset%_mem[k].alignWidth)
                                                                    _offset+=_mem[k].alignWidth-_offset%_mem[k].alignWidth;
                                                         _offset+=_mem[k].width;
                                        }
                                        if(_offset%_mem[j].alignWidth)
                                                         _offset+=_mem[j].alignWidth-_offset%_mem[j].alignWidth;
                                        _offset+=_mem[j].width;
                                        for(      ;k<j;++k)
                                       {
                                                          if(_offset%_mem[k].alignWidth)
                                                                     _offset+=_mem[k].alignWidth-_offset%_mem[k].alignWidth;
                                                          _offset+=_mem[k].width;
                                        }
                                        if(_offset<_width)
                                       {
                                                       _width=_offset;
                                                       _index=i;
                                        }
                          }
//�ƶ�����,�����¾ֲ��ĳ�Ա���ݵ�ƫ����
                         if(_index  !=  j )
                        {
                                      mem=_mem[  j  ];
                                      for(  k=j;k>_index;--k  )
                                                   _mem[k]=_mem[k-1];
                                      _mem[ _index ]=mem;
                         }
                         printf("_index:%d, _offset:%d\n",_index,_width);
             }
  }
//***********************************************************************
      int        main(int    argc,char    *argv[])
     {
//��0����ԱΪһ����Ԫ
                     struct           Member             _mem[13]={ {0,4},     {1,1},{4,4},{1,1},{8,8},
                                                                                                 {4,4},{1,1},{8,8},{2,2},
                                                                                                 {1,1},{4,4},{2,2},{4,4}
                                                                                          };
                    const           int                        _size=13;
                    
                    struct_member_total_size(_mem,_size);
                    return    0;
      }