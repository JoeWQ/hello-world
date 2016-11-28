/*
  *@aim:数学双目运算符
  *@note:此类不能像数组索引那样使用跳转式的优化，也就是将不相邻的数据进行累加
  *@date:2015/10/6
  */
  package    inter;
  import     lexer.Type;
  import     lexer.Word;
  import     lexer.Token;
  import     lexer.Num;
  import     lexer.Float;
  import     lexer.Char;
    
  public    class    Mod    extends    Arith
 {
            public     Mod(Expr    _left,Expr   _right)
           {
                         super(Word.mod,_left,_right);
//表达式必须是整数
                        if( (_left.type != Type.Int && _left.type != Type.Char) || (_right.type != Type.Int && _right.type != Type.Char)  )
                                         error("syntax error:module operation want all type int or char ,but gived is: "+_left.type+" and "+_right.type);
            }
//生成三地址代码
            public     Expr       gen()
           {
                        Expr     _expr=gen_constant();
                        if( _expr == this )
                                       _expr=new     Mod(left_expr.reduce(),right_expr.reduce());//规约成简化的子表达式
                       return   _expr;
            }
//规约
            public      Expr       reduce()
           {
                        left_expr=left_expr.reduce();
                        right_expr=right_expr.reduce();
                        
                        Expr      _expr=this.gen_constant();
                        if( _expr !=null )
                                    return   _expr;
                        Temp    t=new   Temp(this.type);
                        emit(t+"="+this);
                        return   t;
            }
//reduce   constant
            public       Expr           reduceConstant()
           {
                        Expr     _expr=gen_constant();
                        if( _expr ==null )
                                  _expr=this;
                        return    _expr;
            }
            private    Expr       gen_constant()
           {
                        Expr     _expr=null;
                        if((left_expr instanceof   Constant) && (right_expr instanceof Constant))
                       {
//按照几率较大的依次
                                      if( left_expr.type==Type.Int  )
                                     {
                                                    int        lvalue=((Num)left_expr.tok).value;
                                                    if(right_expr.type==Type.Int)
                                                               _expr=new    Constant(lvalue%((Num)right_expr.tok).value);
                                                    else
                                                               _expr=new    Constant(lvalue%((Char)right_expr.tok).value);
                                      }
                                      else
                                    {
                                                  char       lvalue=((Char)left_expr.tok).value;
                                                  if(right_expr.type==Type.Int)
                                                              _expr=new    Constant(lvalue%((Num)right_expr.tok).value);
                                                  else
                                                              _expr=new   Constant(lvalue%((Char)right_expr.tok).value);
                                     }
                        }
                        return    _expr;
            }
            public     String     toString()
           {
                        return     left_expr.toString()+this.tok.toString()+right_expr.toString();
            }
  }