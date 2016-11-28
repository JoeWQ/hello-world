/*
  *@aim:��ָ��ȡֵ����
  *@date:2015-10-28 18:12:44
  *@author:�ҽ���
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
//����Ƿ���ָ������
                         if(! (_expr.type  instanceof   Pointer) && !(_expr.type instanceof Array))
                                       error("syntax error:value operator * cannot apply to type "+_expr.type);
                         this.expr=_expr;
                         if(_expr.type  instanceof  Pointer)
                                  this.type=((Pointer)_expr.type).type;
                         else
                                  this.type=((Array)_expr.type).type;
             }
//���ɴ���,���ڻ������Ż�����д������
             public       Expr         gen()
            {
                          expr=expr.reduce();
                          return  this;
             }
//��ԼΪ��һ�ı��ʽ,ע�����������Ļ�,��Լ�ɵı�������ָ������
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