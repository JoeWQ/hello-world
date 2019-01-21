#include<iostream>
#include<time.h>
#include"findarr.h"
using namespace std;
int main()
{
	int parray[10]={0,9,8,7,6,5,4,3,2,1};
    int i=0;
	int value=56;
	bool isFound=false;
	isFound=CFindArray(value,parray,10);
	if(isFound)
		cout<<"在C过程中发现目标数字"<<value<<endl;
	else
		cout<<"没有在C过程中发现目标数字"<<value<<endl;
    isFound=ASMFindArray(value,parray,10);
	if(isFound)
		cout<<"发现目标数字"<<value<<endl;
	else
		cout<<"没有在汇编过程中发现目标数字"<<value<<endl;	
	const unsigned ARRAY_SIZE=10000;
//	printArray(parray,10);
	/*
	const unsigned LOOP_SIZE = 400000;
	int array[ARRAY_SIZE]; 
	for(unsigned j = 0; j < ARRAY_SIZE; j++)
     array[i] = rand();

	int searchVal;
	time_t startTime, endTime;
    searchVal=56;
	cout << "Please wait. This will take between 10 and 30 seconds...\n";


// Test the C++ function:

	time( &startTime );
	bool found = false;

	for( int n = 0; n < LOOP_SIZE; n++)
		found = CFindArray( searchVal, array, ARRAY_SIZE );

	time( &endTime );
	cout << "Elapsed CPP time: " << long(endTime - startTime) 
		<< " seconds. Found = " << found << endl;

// Test the Assembly language procedure:

	time( &startTime );
	found = false;

	for(int nn=0;nn< LOOP_SIZE;nn++)
		found = ASMFindArray( searchVal, array, ARRAY_SIZE );

	time( &endTime );
	cout << "Elapsed ASM time: " << long(endTime - startTime) 
		  << " seconds. Found = " << found << endl;
		  */

	return 0;
}