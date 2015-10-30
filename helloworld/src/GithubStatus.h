#include <iostream>
#include <folly/Uri.h>
#include <folly/Subprocess.h>
#include <folly/gen/Base.h>

class GithubStatus {
	public: 
		static std::vector<folly::Uri> getUrls();
		static void printStatuses();
};
