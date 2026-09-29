# frozen_string_literal: true

module StarFetcher
  # Parsed fields of /etc/os-release that star-fetcher cares about.
  OsRelease = Struct.new(:id, :id_like, :name, :pretty_name, :version_id, keyword_init: true)

  # Detects the running distribution and decides which logo/theme to use.
  class Distro
    # Logo gradients (RGB), keyed by logo name. openSUSE uses its signature
    # green; the variants get slight variations so they remain distinguishable.
    GRADIENTS = {
      "opensuse" => [[115, 186, 37], [61, 128, 19]],
      "opensuse_leap" => [[115, 186, 37], [46, 125, 50]],
      "opensuse_tumbleweed" => [[115, 186, 37], [26, 107, 60]],
      "opensuse_microos" => [[48, 186, 120], [15, 118, 110]]
    }.freeze
    DEFAULT_GRADIENT = [[115, 186, 37], [61, 128, 19]].freeze

    attr_reader :os

    def self.detect
      new(parse_os_release)
    end

    def self.parse_os_release(path = "/etc/os-release")
      data = {}
      File.foreach(path) do |line|
        next if line.start_with?("#") || !line.include?("=")

        key, value = line.strip.split("=", 2)
        data[key] = value.to_s.gsub(/\A"|"\z/, "")
      end

      OsRelease.new(
        id: data["ID"].to_s,
        id_like: data["ID_LIKE"].to_s,
        name: data["NAME"].to_s,
        pretty_name: data["PRETTY_NAME"].to_s.empty? ? data["NAME"].to_s : data["PRETTY_NAME"],
        version_id: data["VERSION_ID"].to_s
      )
    end

    def initialize(os)
      @os = os
    end

    # Any RPM/zypper based SUSE family member.
    def suse?
      probe = "#{os.id} #{os.id_like}".downcase
      probe.include?("suse") || probe.include?("opensuse")
    end

    def wsl?
      return @wsl unless @wsl.nil?

      osrelease = File.read("/proc/sys/kernel/osrelease")
      @wsl = osrelease.downcase.include?("microsoft")
    rescue SystemCallError
      @wsl = false
    end

    # Name (without extension) of the ASCII artwork to load.
    def logo_name
      return "opensuse" unless suse?

      id = os.id.downcase
      name = os.name.downcase

      if id.include?("tumbleweed") || name.include?("tumbleweed") || os.version_id.casecmp?("tumbleweed")
        "opensuse_tumbleweed"
      elsif id.include?("micro") || name.include?("micro")
        "opensuse_microos"
      elsif id.include?("leap") || name.include?("leap") || os.version_id.match?(/\A\d/)
        "opensuse_leap"
      else
        "opensuse"
      end
    end

    def gradient
      GRADIENTS.fetch(logo_name, DEFAULT_GRADIENT)
    end

    def hostname
      Etc.uname[:nodename]
    rescue StandardError
      ENV["HOSTNAME"]
    end
  end
end
