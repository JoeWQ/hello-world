/*
  *@aim:对指针取值运算
  *@date:2015-10-28 18:12:44
  *@author:狄建彬
  */
  package    inter;
  
  import     lexer.Pointer;
  import     lexer.Type;
  import     lexer.Array;
  import     lexer.Word;
  
  public       class     Value     extends     Expr
 {
             protected       Expr        expr;
             
             public     Value(Expr    _expr)
            {
                          super(Word.pointer,_expr.type);
//检测是否是指针类型
                         if(! (_expr.type  instanceof   Pointer) && !(_expr.type instanceof Array))
                                       error("syntax error:value operator * cannot apply to type "+_expr.type);
                         this.expr=_expr;
                         if(_expr.type  instanceof  Pointer)
                                  this.type=((Pointer)_expr.type).type;
                         else
                                  this.type=((Array)_expr.type).type;
             }
//生成代码,现在还不讲优化步骤写入其中
             public       Expr         gen()
            {
                          expr=expr.reduce();
                          return  this;
             }
//规约为单一的表达式,注意如果是数组的话,规约成的变量将是指针类型
             public      Expr          reduce()
            {
                         this.gen();
                         Temp   t=new    Temp(type);
                         
                         emit(t+"= *"+expr);
                         return   t;
             }
//
             public       String    toString()
            {
                         return     "*"+expr;
             }
  }