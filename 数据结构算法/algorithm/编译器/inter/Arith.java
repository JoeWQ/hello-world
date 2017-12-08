/*
  *@aim:数学双目运算符
  *@与具体的运算符不同,此类只提供基本的代码生成，若想使用编译器的优化功能,
  *@请使用具体的相关子类
  *@date:2015/10/6
  */
  package    inter;
  import     lexer.Type;
  import     lexer.Word;
  import     lexer.Token;
  
  public    class    Arith    extends    Op
 {
 //左右子表达式
            Expr        left_expr;
            Expr        right_expr;
 //
            public     Arith(Token   tok,Expr    _left,Expr   _right)
           {
                         super(tok,null);
                         this.left_expr=_left;
                         this.right_expr=_right;
//检测是否是可进行数学计算的类型
                         if( (this.type=Type.maxType(_left.type,_right.type))==null  )
                                     error("syntax error,Arith type is not match.want 'int' or 'char' ,but gived is: "+_left.type+" and "+_right.type);
//对编译时计算进行分析
            }
//是否可以规约为常量,如果可以则返回常量表达式否则返回自身,子类需要覆盖子函数
            public          Expr           reduceConstant()
           {
                          return   this;
            }
//生成三地址代码
            public     Expr       gen()
           {
                        return    new     Arith(this.tok,left_expr.reduce(),right_expr.reduce());//规约成简化的子表达式
            }
            public     String     toString()
           {
                    //    throw   new   Error("invalide  operate");
                        return     left_expr.toString()+this.tok.toString()+right_expr.toString();
            }
  }