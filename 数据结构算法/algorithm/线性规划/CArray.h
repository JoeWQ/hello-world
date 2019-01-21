/*
  *@aim:һά����
  */
  #ifndef    _CARRAY_H__
  #define   _CARRAY_H__
  #include<stdlib.h>
  template<typename   _type_>
    class    CArray
   {
 //����ѡ���Ե�ѡ��ʹ��ֱ�����û���ʹ����������,���ǹ��ڷ�������ĳ��ȵ�Ȩ�����������
 public:
             _type_               *array;
             int                     size;
private:
//            _type_               *array;
//            int                     size;
private:
            CArray(CArray &);
public:
            CArray(int           _size)
           {
                        array=(_type_ *)malloc(sizeof(_type_)*_size);
                        this->size=_size;
            }
            ~CArray()
           { 
                       free(array);
            }
            inline          int            length()
           {
                       return       size;
            }
            inline          _type_          get(int      idx)
           { 
                       return               array[idx];
            }
            inline         void               set(int     idx,_type_       c)
           {
                      array[idx]=c;
            }
            inline         void               fillWith(_type_     c)
           {
                        int         i=0;
                        _type_   *x=array;
                        while(i++<size)
                                *(x++)=c;
            }
            inline       void               copyWith(CArray<_type_>   *other)
           {
                        _type_         *x=this->array;
                        _type_         *y=other->array;
                        int                i=0;
                        while( i++<other->size)
                                 *(x++)=*(y++);
            }
            inline        void           copyWith(CArray<_type_>   *other,int   _size)
           {
                         _type_        *x=this->array;
                         _type_        *y=other->array;
                         int               i=0;
                         while(i++<_size)
                                   *(x++)=*(y++);
            }
    };
  #endif