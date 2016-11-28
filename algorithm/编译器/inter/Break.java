/*
  *@aim:breakÓï¾ä
  *@date:2015-10-07 12:56:07
  */
  package    inter;
  
  public    class    Break  extends   Stamt
 {
             private     Stamt    stamt;
             public     Break()
            {
                         if(Stamt.Enclosing==Stamt.Null)
                                    error("syntax error, unenclosing break.");
                         stamt=Stamt.Enclosing;
             }
//Éú³É´úÂë
             public      void    gen(int  _after,int  _before)
            {
                          emit("jmp   L"+stamt.after);
             }
  }