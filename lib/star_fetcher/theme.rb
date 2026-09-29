# frozen_string_literal: true

module StarFetcher
  # ANSI true-color helpers. Every method is a no-op when colors are disabled,
  # so callers do not have to branch on TTY/`--no-color`.
  class Theme
    RESET = "\e[0m"

    attr_reader :enabled

    def initialize(enabled: true)
      @enabled = enabled
    end

    def rgb(red, green, blue)
      return "" unless enabled

      "\e[38;2;#{red};#{green};#{blue}m"
    end

    def bg(red, green, blue)
      return "" unless enabled

      "\e[48;2;#{red};#{green};#{blue}m"
    end

    def reset
      enabled ? RESET : ""
    end

    def paint(text, rgb: nil, bold: false)
      return text unless enabled

      codes = +""
      codes << "\e[1m" if bold
      codes << self.rgb(*rgb) if rgb
      codes.empty? ? text : "#{codes}#{text}#{RESET}"
    end

    # Tint each visible character with a horizontal gradient between two RGB
    # colors, leaving whitespace untouched so the artwork keeps its shape.
    def gradient(text, from:, to:)
      return text unless enabled

      width = [text.length - 1, 1].max
      text.each_char.with_index.each_with_object(+"") do |(char, index), out|
        if char == " " || char == "\t"
          out << char
        else
          out << rgb(*lerp(from, to, index.to_f / width)) << char << RESET
        end
      end
    end

    private

    def lerp(from, to, ratio)
      from.zip(to).map { |start, finish| (start + (finish - start) * ratio).round }
    end
  end
end
