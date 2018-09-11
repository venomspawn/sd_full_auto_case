install:
	bundle install

debug:
	bundle exec bin/irb_debug

test:
	bundle exec rspec --fail-fast

build:
	gem build sd_full_auto_case.gemspec

.PHONY: doc
doc:
	bundle exec yard doc --quiet

.PHONY: doc_stats
doc_stats:
	bundle exec yard stats --list-undoc
