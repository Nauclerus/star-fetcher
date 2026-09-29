# frozen_string_literal: true

module StarFetcher
  # Draws the neofetch-style two-column layout: ASCII artwork on the left,
  # the collected info rows on the right, then a palette strip underneath.
  class Render
    GUTTER = "   "
    PALETTE = [
      [0x00, 0x00, 0x00], [0xcc, 0x00, 0x00], [0x4e, 0x9a, 0x06], [0xc4, 0xa0, 0x00],
      [0x34, 0x65, 0xa4], [0x75, 0x50, 0x7b], [0x06, 0x98, 0x9a], [0xd3, 0xd7, 0xcf]
    ].freeze

    def initialize(theme:, distro:, logo:, lines:)
      @theme = theme
      @distro = distro
      @logo = logo
      @lines = lines
    end

    def to_s
      body = body_lines.join("\n")
      "#{header}\n#{body}\n\n#{palette}\n"
    end

    private

    def header
      title = "#{username}@#{@distro.hostname}"
      line = "-" * title.length
      "#{@theme.paint(title, rgb: [0x73, 0xba, 0x25], bold: true)}\n" \
        "#{@theme.paint(line, rgb: [0x73, 0xba, 0x25])}"
    end

    def username
      Etc.getlogin || Etc.getpwuid(Process.uid)&.name || ENV["USER"] || "user"
    rescue StandardError
      ENV["USER"] || "user"
    end

    def body_lines
      info = @lines.map { |line| info_row(line) }
      logo_width = @logo.lines.map(&:length).max || 0
      height = [@logo.lines.length, info.length].max

      Array.new(height) do |index|
        raw = @logo.lines[index].to_s
        tinted = colorize(raw)
        padding = " " * (logo_width - raw.length)
        right = info[index].to_s
        right.empty? ? tinted : "#{tinted}#{padding}#{GUTTER}#{right}"
      end
    end

    def colorize(raw)
      from, to = @distro.gradient
      @theme.gradient(raw, from: from, to: to)
    end

    def info_row(line)
      label = @theme.paint(line.label, rgb: [0x73, 0xba, 0x25], bold: true)
      value = @theme.paint(line.value, rgb: [0xe6, 0xe6, 0xe6])
      "#{label}: #{value}"
    end

    def palette
      PALETTE.map { |rgb| "#{@theme.bg(*rgb)}  #{@theme.reset}" }.join
    end
  end
end
