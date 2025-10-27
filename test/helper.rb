# Disable plugins to avoid loading Activesupport
ENV["MT_NO_PLUGINS"] = "1"

require "minitest/autorun"
require_relative "../lib/toml-rb"
