#include <gtest/gtest.h>
#include <folly/Uri.h>
#include "GithubStatus.h"

TEST(GithubStatusTests, fetch_urls_returns_correct_urls) {
	// This is a bit of a pointless test, but shows some basic
	// gtest usage
	std::vector<folly::Uri> expected {
		folly::Uri("https://status.github.com:443/api/status.json"),
		folly::Uri("https://status.github.com:443/api/last-message.json"),
	};
	auto urls = GithubStatus::getUrls();

	ASSERT_EQ(expected.size(), urls.size());
	for (int i = 0; i < expected.size(); i++) {
		ASSERT_EQ(expected[i].str(), urls[i].str()); 
	}
}
