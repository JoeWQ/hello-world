extern "C" bool CFindArray(int searchVal,int *array,int count);
bool CFindArray(int searchVal,int *array,int count)
{
	int i=0;
	for(;i<count;++i)
	{
		if(array[i]==searchVal)
			return true;
	}
	return false;
}