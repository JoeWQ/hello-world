/*
  *@aim:指针加法
  *@date:2015-10-28 17:15:56
  *@author:狄建彬
  */
  package    inter;
  import     lexer.Type;
  import     lexer.Pointer;
  import     lexer.Struct;
  import     lexer.Num;
  import     lexer.Char;
  import     lexer.Token;
  import     lexer.Word;
  import     lexer.Array;
//
  public        class     PointerAdd    extends    Expr
 {
//指针加法的左右子表达式
               protected       Expr         left;
                protected      Expr         right;
//
               public     PointerAdd(Expr   _left,Expr   _right)
              {
                              super(Word.add,Type.Int);
//对表达式检测,或者left为指针类型right为整数类型,或者反过来,否则要报错
                             boolean       match=false;
                             left=_left;
                             right=_right;
                             if(_left.type==Type.Int || _left.type==Type.Char)
                            {
                                            match=(_right.type instanceof Pointer)||(_right.type instanceof Array);
                                            left=_right;
                                            right=_left;
                             }
                             else if(_right.type==Type.Int || _right.type==Type.Char)
                                            match=(_left.type instanceof Pointer)||(_left.type instanceof Array);
                             if(!match)
                                        error("syntax error:pointer type usage error,cannot apply pointer operator to type '"+_left.type+"'  and  '"+"' "+_right.type);
                            this.left=_left;
                            this.right=_right;
//改变类型
                             this.type=left.type;
               }
//产生右侧代码,生成一个临时指针类型
               public      Expr      gen()
              {
//生成新的表达式
                          left=left.reduce();
                          right=right.reduce();
                          return   this;
               }
//生成三地址代码,现在暂时不优化,留待下一个版本
               public      Expr        reduce()
              {
                           this.gen();
                           Temp    t=new    Temp(left.type);
                           int             offset=0;
                           int             width=0;
//如果左侧是指针 
                           if( left.type  instanceof  Pointer)
                                       width=((Pointer)left.type).type.width;
                           else
                                       width=((Array)left.type).type.width;
//不要忘记还有一次乘法
                          if( right  instanceof   Constant  )
                         {
                                          Constant     n=(Constant)right;
                                          if(right.type  == Type.Int)
                                                    offset=((Num)n.tok).value;
                                          else
                                                    offset=((Char)n.tok).value;
                                          emit(t+"="+left+"+"+offset*width);
                          }
                          else
                         {
                                         Temp    m=new   Temp(Type.Int);
                                         emit(m+"="+width+"*"+right);
                                         emit(t+"="+left+"+"+m);
                          }
                           return     t;
               }
//依赖的函数库
               public      String    toString()
              {
                            return     left+"+"+right+"*"+left.type.width;
               }
  }