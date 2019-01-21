/*
  *@aim:符号表
  *@date:2015/10/6
  */
  package     symbol;
  import    java.util.HashMap;
  import    lexer.Token;
  import    inter.Id;
  public   class   Env
 {
//符号表的前驱结点
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
//查找,当前block定义环境中是否已经存在该token
               public     Id    exist_define(Token   tok)
              {
                             return    table.get(tok);
               }
//从当前定义栈中查找
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