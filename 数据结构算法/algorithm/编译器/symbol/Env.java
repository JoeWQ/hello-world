/*
  *@aim:���ű�
  *@date:2015/10/6
  */
  package     symbol;
  import    java.util.HashMap;
  import    lexer.Token;
  import    inter.Id;
  public   class   Env
 {
//���ű��ǰ�����
               public     Env        prev;
               private    HashMap<Token,Id>      table;
               public     Env(Env   _env)
              {
                             this.prev=_env;
                             table=new     HashMap<Token,Id>();
               }
//put 
               public     void      put(Token  _tok,Id    _id)
              {
                             table.put(_tok,_id);
               }
//����,��ǰblock���廷�����Ƿ��Ѿ����ڸ�token
               public     Id    exist_define(Token   tok)
              {
                             return    table.get(tok);
               }
//�ӵ�ǰ����ջ�в���
               public    Id       get(Token     tok)
              {
                             Env    env=this;
                             for(    ;env!=null;env=env.prev)
                            {
                                          Id     id=env.table.get(tok);
                                          if(id!=null)
                                                       return     id;
                             }
                             return    null;
               }
  }