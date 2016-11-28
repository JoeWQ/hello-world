/*
  *@aim:数组类型
  *@date:2015/10/6
  */
  package    lexer;
  public     class     Array   extends   Type
 {
//数组中元素的数目
              public     final       int        size;
//数组中所存放的元素的类型，注意此类型可能为Array本身,也就是递归类型
              public     final       Type     type;
//_size:数组中元素的数目
              public     Array(int   _size,Type   _type)
             {
//数组的对其粒度为其内容元素的对其粒度
                           super("[]",Tag.INDEX,_size*_type.width,_type.alignWidth);
                           this.size=_size;
                           this.type=_type;
              }
              public     String      toString()
             {
                           return      type+"["+this.size+"]";
              }
//通用函数,用于函数调用中数组向指针赋值的时候,判断两者是否是兼容的
//参数的含义正如其名字
//根据我们的假设,任何一个非基本类型,在全局中只能有个对象存在,所以判断过程就可以极大地简化了
             public      static      boolean       isCompatible(Array     left_value,Array     right_value)
            {
//左右两者数组中所装载的对象
 //                          Type      lp,rp;
//判断装载的类型是否一样
                           return        left_value.type==right_value.type;
             }
  }