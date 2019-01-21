/*
  *文件管理器
  *2016-1-7 15:35:19
  */
  import       java.io.File;
  import       java.io.InputStream;
  import       java.io.PrintStream;
  
  public        class      FileManager
 {
              public     static     InputStream     input;
              public     static     PrintStream      output;
              
              public     static    void      initWith(InputStream   _input,PrintStream   _output)
             {
                         input=_input;
                         output=_output;
             }
  }