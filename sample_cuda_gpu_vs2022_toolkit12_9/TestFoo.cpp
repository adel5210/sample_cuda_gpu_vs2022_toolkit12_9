#include "TestFoo.h"
#include <stdio.h>
#include <iostream>


extern "C" __declspec(dllexport)
void someMethod()
{
	std::cout << "IT WORKS" << "\n";
}
