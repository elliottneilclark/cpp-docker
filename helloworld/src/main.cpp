#include <iostream>
#include "GithubStatus.h"

int main(int arg, char** argv) {
	std::cout << "Hello, world! Let's check on github!" << std::endl;
	GithubStatus::printStatuses();
}
