/*
  *@aim:��������
  *@date:2015-10-19
  *@author:�ҽ���
  *@version:3
  *@date:2015-11-5 11:45:04
  *@aim:�����˽ṹ���ָ��
  */
  package   inter;
   import    lexer.Func;
   import    lexer.Type;
   import    lexer.Struct;
   import    lexer.Pointer;
   import    lexer.Array;
   import    lexer.Token;
   import    java.util.ArrayList;
   public    class    Call     extends     Expr
  {
//Ҫ���õĺ���
                public       final        Func                        func;
//�����ʵ���б�
                public       final        ArrayList<Expr>    param;
//ȫ�ֿղ�������,Ϊ�˷������ı�д�����ⴴ��������û�����ݷֵ��б�
                public       static      final      ArrayList<Expr>      glogalNull=new    ArrayList<Expr>();
                public       Call(Func     _func,ArrayList<Expr>   _param)
               {
                                super(_func,_func.returnType);
                                this.func=_func;
                                this.param=_param;
//�������ĺϷ���
                                if(_param.size() != _func.paramList.size())
                                                    error("syntax error:function "+_func+" want  param count is "+_func.paramList.size()+"   but    real   gived  is : "+_param.size());
                                int    i=0;
                                for(     ;i<_func.paramList.size();++i)
                               {
                                                 if( !this.isCompatible(_param.get(i).type,_func.paramList.get(i) ) )
                                                              error("syntax error:function '"+func+"' want type "+_func.paramList.get(i)+"  ,but  gived type '"+_param.get(i).type+"' is not compatible. ");
                                }  
                }
//�������Ƿ����,�������ǽ��ϸ���������,���Ժ�İ汾�����ǽ�������ָ��ͽṹ���ͣ�
//��������ֻ���û�������ֵ����
//�β�q���Ÿ�Ϊ��������
//ע��ָ�����ͺ���������֮���΢��ĵȼ۹�ϵ
                public       boolean      isCompatible(Type    p,Type   q)
               {
                                Integer      p1=Type.priority.get(p);
                                Integer      p2=Type.priority.get(q);
                                if(p1!=null && p2!=null  )
                               {
                                            int   v1=p1.intValue();
                                            int   v2=p2.intValue();
                                            if(v1>0 && v2>0    )
                                                           return    v2>=v1;
                                            return   v1==0 && v2==0;
                                }
                                else if( p1 !=null || p2 !=null   )//�������ͺͽṹ���͵�ƥ��ע��Ҫʧ��
                                            return    false;
//Ϊ�˳���Ŀɶ���,��д�ıȽ���ɢ
//��������֮��ıȽ�,��Ϊ�ṹ����֮��,ָ������֮��,������ָ������֮��
                                if(( p instanceof   Struct )&&(q instanceof Struct) )
                                           return   p.equalWith(q);
//�����ָ����ָ��֮��
                                if( ( p instanceof  Pointer) &&(q instanceof Pointer))
                                           return    p.equalWith(q);
//�����ָ��������������,ע��ֻ��q�п�����ָ��q������Ϊ����
                                if( (p instanceof   Array) && (q instanceof  Pointer))
                               {
                                           Array             _array1=(Array)p;
                                           Pointer          _pt1=(Pointer)q;
                                           
                                           return     _array1.type.equalWith(_pt1.type);
                                }
                                return false;
                }
//@date:2015-10-20 11:09:50
//��⺯����������ʵ�ʵ�ʵ���Ƿ�ƥ��,���ﲻ�������
               public    boolean         isFuncDeclTypeMatch(Func   func1,Func    func2)
              {
                           boolean        match=true;
                           int                 i=0;
                           if( func1.paramList.size() != func2.paramList.size()  )
                                           error("syntax error:function "+func1.lexeme+ " defined do not match it declared :param list length is not same. ");
                           StringBuilder  build=new    StringBuilder("syntax error:function ");
                           build.append(func1.lexeme).append(" ");
                           for(    ;i<func1.paramList.size();++i)
                          {
//���ͼ��
                                          if(  func1.paramList.get(i) != func2.paramList.get(i) )
                                        {
                                                         build.append(" want type ").append(func1.paramList.get(i)).append(",but real type is:").append(func2.paramList.get(i)).append("\n");
                                                         match=false;
                                         }
                           }
                           if( !match  )
                                        error(build.toString());
                           return    match;
                }
//�����������ô���,��������ַָ����Ҳ�,ע��ʵ�μ����˳���Ǵ��������
                public       Expr       gen()
               {
                               ArrayList<Expr>      _param=new    ArrayList<Expr>(param.size());
                               int        i;
                               for(i=0;i<param.size();++i)
                                            _param.add(null);
                               i=param.size()-1;
//                               System.out.println("_param.size():"+_param.size());
                               for(    ;i>=0;--i)
                                               _param.set(i,param.get(i).reduce());
                               return    new     Call(this.func,_param);
                }
//��Լ��������
                public      Expr      reduce()
               {
                               StringBuilder     build=new    StringBuilder();
                               Expr    expr=this.gen();
                               Temp    tmp=new   Temp(func.returnType);
//ѹ���β��б�
                               build.append(tmp).append(" = ").append(expr);
                               emit(build.toString());
                               return     tmp;
                }
                public      String    toString()
               {
                                int        i=0;
//ʹ��callָ����ú���
                               StringBuilder     build=new    StringBuilder("@call\t\t");
                               build.append(func.lexeme);
                               if(param.size()>0)
                                           build.append(":\t");
//ѹ���β��б�
                               for(   ;i<param.size();++i)
                                           build.append(param.get(i)).append("  ");
                               return    build.toString();
                }
   }