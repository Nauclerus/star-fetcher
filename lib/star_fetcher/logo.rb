# frozen_string_literal: true

module StarFetcher
  # Loads ASCII artwork bundled in the repository's +ascii/+ directory.
  class Logo
    DIRECTORY = File.expand_path("../../ascii", __dir__)
    FALLBACK = "opensuse"

    def self.available
      Dir.glob(File.join(DIRECTORY, "*.txt"))
         .map { |path| File.basename(path, ".txt") }
         .sort
    end

    attr_reader :name, :lines

    def initialize(name)
      @name = name
      path = File.join(DIRECTORY, "#{name}.txt")
      path = File.join(DIRECTORY, "#{FALLBACK}.txt") unless File.exist?(path)

      raw = File.read(path).lines.map(&:chomp)
      # Drop trailing empty lines so the artwork lines up with the info column.
      raw.pop while raw.last&.empty?
      @lines = raw
    end
  end
end
