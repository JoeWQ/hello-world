/*
  *@aim:return���
  *@date:2015-10-20 11:22:34
  *@author:�ҽ���
  */
  package    inter;
  import      lexer.Type;
  import      lexer.Word;
  import      lexer.Func;
  import      lexer.Struct;
  import      lexer.Pointer;
  import      lexer.Array;
//ע��return���ı��ʽ����Ϊ��Void.Null,����return��䲻�������ʽ������
   public     class      Return      extends    Stamt
  {
                  private          Func           func;
                  private          Expr           expr;
//������Χ����
                  public       Return(Expr    _expr)
                 {
 //                               super(Word._return,null);
//�ȼ����Χ����
                                if(Func.Enclosing ==Func.Null )
                                              error("syntax error:return express do not enclose.");
                                this.func=Func.Enclosing;
                                this.expr=_expr;
//�ڼ�ⷵ�ص������Ƿ�һ�»��߼���
                                boolean     gen_error=false;
                                if(func.returnType!=Type.Void)
                               {
//����������Ͳ�����,��ǰ������ʱ���ú�������ָ��/�ṹ��,�����ں����İ汾�����ǽ�ʵ����Щ����
//@date:2015-11-5 14:59:27
//@version:ʵ�ֿ��Է��ظ������͵�����
                                             Integer       a=Type.priority.get(func.returnType);
                                             Integer       b=Type.priority.get(_expr.type);
                                             if( a!=null && b!=null)
                                            {
                                                               int        v1=a.intValue();
                                                               int        v2=b.intValue();
                                                               if(  v1>0 && v2>0  )
                                                                            gen_error=v1<v2;
                                                               else 
                                                                            gen_error=v1>0 || v2>0;
                                             }
                                             else
                                           {
                                                             gen_error=true;
                                                              if( (func.returnType instanceof Struct) && (_expr.type instanceof Struct))
                                                                           gen_error=!func.returnType.equalWith(_expr.type);
                                                              if(func.returnType instanceof    Pointer)
                                                             {
                                                                            Pointer   _p1=(Pointer)func.returnType;
                                                                            if(_expr.type instanceof  Pointer)
                                                                                          gen_error=!_p1.type.equalWith(((Pointer)_expr.type).type);
                                                                            else if(_expr.type instanceof Array)
                                                                                          gen_error=!_p1.type.equalWith(((Array)_expr.type).type);
                                                              }
                                             }
                                }
                                else 
                                            gen_error=_expr.type!=Type.Void;
                               if(    gen_error    )
                                                 error("syntax error: function type "+func.returnType+" is not compatible with return type "+_expr.type);
//Ϊ�������ϱ�־����ʾ�з���������
                               func.hasReturnStamt=true;
                  }
//���ɴ���
                  public     void        gen(int   _after,int   _before)
                 {
                                  if(  expr.type!=Type.Void )
                                 { 
                                                   Expr      p=expr.gen();
                                                   Temp    t=new    Temp(p.type);
                                                   emit(t+"="+p);
                                                   emit("return  "+t);
                                  }
                                  else
                                                  emit("return");
                  }
//ע��һ������ĺ������ᱻ����,��Ϊreturn��䲻�������ʽ����
                  public     String       toString()
                 {
                                if( expr.type != Type.Void  )
                                               return     "return  "+expr;
                                return   "return";
                  }
   }