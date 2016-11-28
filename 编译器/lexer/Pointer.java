/*
  *@aim:指针类型
  *@date:2015-10-24 18:57:28
  *@author:狄建彬
  */
  package      lexer;
  public    class    Pointer   extends    Type
 {
//固定类型,字符串指针
              public     static     final     Pointer     CharPointer=new     Pointer(Type.Char);
//指针所指向的类型
              public     final       Type      type;
//
              public      Pointer(Type     _type)
             {
//词法单元 所指向的类型名子+*,对齐丽都4,所占据的空间4
                           super(_type+"*",Tag.POINTER,4,4);
                           this.type=_type;
              }
//判断类型是否等价,根据我们的假设,每种类型在全局内只有一个对象
              public   static       boolean      compare_pointer(Pointer   p,Pointer   q)
             {
                           return     p==q;
              }
//
              public     String      toString()
             {
                           return     type+"*";
              }
  }