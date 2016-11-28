/*
  *@aim:访问结构体,以引用的形式,
  *@date:2015-10-28 18:42:50
  *@author:狄建彬
  */
  package    inter;
  import     lexer.Struct;
  import     lexer.Type;
  import     lexer.Pointer;
  import     lexer.Member;
  import     lexer.Word;
 //
  public       class        AccessStruct    extends    Expr
 {
//注意访问结构体有两种方式,其一是指针访问,其二是点号访问
//两种访问的优先级是相同的,都是最高
 //结构体的类型是隐含在其中的
               private      Expr              id;
//访问的成员的相对偏移计算,就像对数组的访问那样
               private      Expr              index;
//_type:要访问的类型,
//               private      Type              type;
//_struct目标结构体
//_index:构成要访问的阶梯的相对地址计算,_index最后一定是一个整数常量,否则要报错
               public       AccessStruct(Expr    _id,Expr   _index,Type   _type)
              {
                                 super(Word.access_struct,_type);
//类型判断,_id或者为一个结构体变量,或者为一个指向结构体的指针
                                if(! (_id.type   instanceof   Struct))
                                               error("syntax error:"+_id+" must be struct type,but gived is "+_id.type);
//访问成员的路径
                                 if(!( _index.type==Type.Int))
                                               error("syntax error:access struct member must be through integer   constant,but gived "+_index);
                                 this.id=_id;
                                 this.index=_index;
               }
//生成右侧代码
               public     Expr       gen()
              {
//如果结构是由指针生成的
                                if(  id   instanceof    Value )
                                             return     new     AccessStructByPointer(((Value)id).expr,index.reduce(),type);

                                id=id.reduce();
                                index=index.reduce();
                                return  this;
               }
//规约为单一的变量
               public           Expr                reduce()
              {
                               Expr   _expr=this.gen();
                               Temp    t=new     Temp(this.type);
//如果标识符是一个结构体变量
                               emit(t.type+"\t\t"+t+"="+_expr);
                               return        t;
              }
              public        String     toString()
             {
                             return     id+"["+index+"]";
              }
  }