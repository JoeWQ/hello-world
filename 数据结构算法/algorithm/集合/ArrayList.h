//������,������ģ��
#ifndef    __ARRAY_LIST_H
#define   __ARRAY_LIST_H
// �������ص��ǣ������� ����ҪԶԶ���� ɾ������� ����
//֪ʶ�㣬ƽ̯����
//2013��12��27��
//2014��3��8��
/*
  *�޸ĵĵط���ÿ�����ŵĹ�ģ������ ԭ����2��
  */
#include<stdlib.h>
#include<string.h>
  template<typename   Key>
  class    ArrayList
  {
  private:
// address of array
		   Key         **base;
//  real size
	       int          _size;
// total size
		   int          total_size;
//�����־
		   bool        _clean_flag;
       enum
      {
                default_original_size=8
       };
  public:
	       ArrayList()
        {
		               this->base =(Key **)malloc(sizeof(Key *)*default_original_size);
	                 this->_size = 0;
		               this->total_size = default_original_size;
		               this->_clean_flag = 0;
         }
//ÿ�� �洢���ݵ�����
	      ~ArrayList()
      {
      		     if(   _clean_flag )
		          {
			                 int   i=0;
			          	     while(i< _size )
			        	      {
				           	      delete     base[i];
					            	  ++i;
				              }
		          }
	     	      free(base);
      }

//��������  d���� Ԫ��ֵ
	Key    *indexOf(int  udx)
 {
	         if(   udx>=0 && udx <_size )
			           return   base[udx];
		       return   NULL;
 }
//����Ԫ��
	void     insert(Key    *y)
 {
	       if(  _size <total_size )
                     base[_size++] = y;
		   else
		   {
//���������� ����Ϊԭ�� ��1.618 ��
			         total_size =(int)(1.618*total_size);
					    Key     **new_base=(Key   **)malloc(sizeof(Key *)*total_size);
					    memcpy(new_base,base,_size*sizeof(Key *));
					    free(base);
					    base = new_base;
					    base[_size++]= y;
		   }
 }
//ɾ�� ���� d ����Ԫ��
	Key     *removeIndexOf(int    udx)
 {
	       int      i;
		     Key    *y=NULL;
	       if( udx>=0 && udx <_size)
		   {
				          	y= base[udx];
				          	for( i=udx; i< _size - 1; ++i   )
				              		  base[i] = base[i+1];
				          	--_size;
//���� ���� ����
//����������Ϊԭ���� total_size ��1/3
                  int      m=(int)(total_size*0.382);
				         	if(  _size <m   && total_size > default_original_size )
			       		 {
						                   total_size =m;
						                   Key    **new_base=(Key **)malloc(sizeof(Key *)*m);
								               memcpy(new_base,base,_size*sizeof(Key *) );
								               free(base);
								               base = new_base;
				        	}
		    }
		   return   y;
  }
//ɾ��Ԫ��
	void     remove(Key   *obj)
 {
	     int    i=0;
		  for( i=0;i<_size;++i )
		  {
			       if( base[i] == obj )
				   {
					          removeIndexOf(i);
						      	break;
				   }
		  }
 }
//����ɾ��,ɾ����Χ[udx_from,udx_to)
 void      remove(int    udx_from,int   udx_to)
{
             if(udx_to<=udx_from)
                     return;
             if(udx_from<0)
                    udx_from=0;
             if(udx_to>this->_size)
                    udx_to=this->_size;
//����
            while(udx_to<_size)
           {
                     this->base[udx_from]=this->base[udx_to];
                     ++udx_from;
                     ++udx_to;
            }
//����base�Ĵ�С
            this->_size-=(udx_from-udx_from);
//����������������total_size ��0.382���ڣ������base
            int    ysize=(int)(this->total_size*0.382);
            if(this->_size<ysize)
           {
                       if( ysize<default_original_size)
                               ysize=default_original_size;
                       Key    *newBase=(Key **)malloc(sizeof(Key *)*ysize);
                       if(this->_size>0)
                           memset(newBase,base,this->_size);
                       this->total_size=ysize;
            }
 }
//���� ɾ����־��0 ��ʾ���� ���� ģ���е� ָ�� ֵ��1��ʾ������ʱ��ɾ���������е�ָ�����
	void     setClearFlag(bool   b)
 {
	     this->_clean_flag = b;
 }
//���� ���� ��ǰ������
	    int       getSize()
    {
        return this->_size;
     }
//��� �����е�����Ԫ��
	   void     clear()
    {
	        	if(   _clean_flag )
	      	{
			             	int   i=0;
			            	while(i< _size )
			           	{
				                		delete     base[i];
				                		++i;
			           	}
		      }
//ֻ���� ԭ����������������һ���Ĺ�ģ��ʱ�򣬲Ż������ͷ��ڴ�
           if(  total_size >default_original_size   )
          {
		              free(base);
		              base = (Key **)malloc(sizeof(Key *)*default_original_size);
		              total_size = default_original_size;
	                _size = 0;
          }
          else
                 _size = 0;
       }
  };
#endif
