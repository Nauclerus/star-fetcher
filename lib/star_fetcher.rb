# frozen_string_literal: true

require "etc"
require "optparse"
require "socket"

require_relative "star_fetcher/version"
require_relative "star_fetcher/theme"
require_relative "star_fetcher/distro"
require_relative "star_fetcher/logo"
require_relative "star_fetcher/modules"
require_relative "star_fetcher/render"
require_relative "star_fetcher/cli"

# A small, dependency-free, neofetch-like system information tool.
module StarFetcher
end
