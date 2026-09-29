# frozen_string_literal: true

module StarFetcher
  # Command line entry point.
  class CLI
    USAGE = <<~TEXT
      Usage: star-fetcher [options]

      Options:
        -l, --logo NAME     Use a specific ASCII logo (see --list-logos)
            --list-logos    List the bundled logos and exit
            --no-color      Disable colored output
        -h, --help          Show this help
        -v, --version       Show the version
    TEXT

    def self.run(argv = ARGV, stdout: $stdout)
      new(argv, stdout: stdout).run
    end

    def initialize(argv, stdout: $stdout)
      @argv = argv.dup
      @stdout = stdout
    end

    def run
      options = parse(@argv)

      case options
      in { action: :help }
        @stdout.puts USAGE
      in { action: :version }
        @stdout.puts "star-fetcher #{VERSION}"
      in { action: :list }
        @stdout.puts Logo.available
      in { action: :render, logo:, color: }
        render(logo: logo, color: color)
      end

      0
    rescue OptionParser::ParseError => e
      warn "star-fetcher: #{e.message}"
      warn USAGE
      1
    end

    private

    def render(logo:, color:)
      distro = Distro.detect
      logo = Logo.new(logo || distro.logo_name)
      theme = Theme.new(enabled: color)
      lines = Modules.new(distro).lines

      @stdout.print Render.new(theme: theme, distro: distro, logo: logo, lines: lines).to_s
    end

    def parse(argv)
      options = { logo: nil, color: @stdout.tty?, action: :render }

      parser = OptionParser.new do |opts|
        opts.banner = USAGE
        opts.on("-l", "--logo NAME") { |name| options[:logo] = name }
        opts.on("--list-logos") { options[:action] = :list }
        opts.on("--no-color") { options[:color] = false }
        opts.on("-h", "--help") { options[:action] = :help }
        opts.on("-v", "--version") { options[:action] = :version }
      end

      parser.parse!(argv)
      options
    end
  end
end
