/*
  *@aim:��ָ�����ʽ���ʽṹ��
  *@date:2015-11-4 11:49:34
  *@author:�ҽ���
  */
  package    inter;
  import       lexer.Struct;
  import       lexer.Type;
  import       lexer.Word;
  import       lexer.Pointer;
  import       lexer.Num;
  public        class       AccessStructByPointer    extends     Expr
 {
//ָ�����ͱ��ʽ
                 public         Expr          expr;
//���ʵ�����
                 public         Expr          index;
//
                 public       AccessStructByPointer(Expr     _expr,Expr      _index,Type   _type)
                {
                                super(Word.assign,_type);
//������ָ������
                               if( !(_expr.type   instanceof    Pointer) || !(((Pointer)_expr.type).type   instanceof   Struct ))
                                                error("syntax error: AccessStructByPointer want  struct  pointer type,but gived is "+_expr.type);
                               if( _index.type != Type.Int )
                                                error("syntax error:AccessStructByPointer want 'int' type ,but gived is "+_index);
                               this.expr=_expr;
                               this.index=_index;
                 }
//��������ַ�����Ҳ�
                 public         Expr        gen()
                {
                                expr=expr.reduce();
                                index=index.reduce();
                                return   this;
                 }
//��ԼΪ��һ�ı���
                 public        Expr            reduce()
                {
                                this.gen();
                                Temp    t=new    Temp(this.type);
                                Num           n=null;
                                if( index instanceof   Constant  ) 
                                             n=((Num)((Constant)index).tok   );
                                if( n ==null || n.value !=0 )
                              {
                                              Temp       t1=new    Temp(this.type);
                                              emit(t1+"="+expr+"+"+index);
                                              emit(t.type+"\t  "+t+"=  *"+t1);
                               }
                               else
                                              emit(t.type+"\t  "+t+"= *"+expr);
                               return   t;
                 }
//
                 public     String      toString()
                {
                              Num          n=null;
                               if( index  instanceof   Constant )
                                              n=(Num)((Constant)index).tok;
                               if(n!=null && n.value ==0 )
                                          return      "*"+expr;
                               return       expr+"["+index+"]";
                 }
  }