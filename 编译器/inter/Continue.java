/*
  *@aim:continue”Ôæ‰
  *@date:2015-10-8 15:33:42
  */
  package    inter;
  
  public    class    Continue   extends     Stamt
 {
              private       Stamt        stamt;
              
              public     Continue()
             {
                           if( Stamt.Enclosing==Stamt.Null )
                                      error("syntaxerror: no enclosing to continue.");
                           this.stamt=Stamt.Enclosing;
              }
              public     void     gen(int   _after,int   _before)
             {
                            emit("jmp    L"+stamt.before);
              }
  }