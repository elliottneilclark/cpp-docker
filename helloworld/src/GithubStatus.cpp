#include "GithubStatus.h"

std::vector<folly::Uri> GithubStatus::getUrls() {
	return std::vector<folly::Uri> {
		folly::Uri("https://status.github.com:443/api/status.json"),
		folly::Uri("https://status.github.com:443/api/last-message.json"),
	};
}

void GithubStatus::printStatuses() {
	folly::gen::from(getUrls())
		| folly::gen::map([](const auto& uri){ return uri.str(); })
		| [](const auto& s) {
			auto options = folly::Subprocess::pipeStdout().pipeStderr();
			std::vector<std::string> argv{ "/usr/bin/curl", "--silent", s };
			std::cout << "Running " << folly::join(' ', argv) << std::endl;
			folly::Subprocess proc(argv, options); 
			auto ret = proc.communicate();
			auto status_code = proc.wait().exitStatus();
			std::cout << "Results from " << s << std::endl 
				<< "Status: " << status_code << std::endl
				<< "Stdout: " << ret.first << std::endl 
				<< "Stderr: " << ret.second << std::endl << std::endl;
		};
}
