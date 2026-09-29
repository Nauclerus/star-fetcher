# frozen_string_literal: true

module StarFetcher
  # Collects the individual "label: value" rows shown next to the artwork.
  # Every probe is defensive: on minimal images a file or tool may be absent,
  # in which case the row is simply omitted instead of crashing.
  class Modules
    Line = Struct.new(:label, :value)

    def initialize(distro)
      @distro = distro
    end

    def lines
      [
        os_line,
        host_line,
        kernel_line,
        uptime_line,
        packages_line,
        shell_line,
        cpu_line,
        memory_line,
        disk_line,
        local_ip_line,
        locale_line,
        timezone_line
      ].compact
    end

    private

    def os_line
      Line.new("OS", @distro.os.pretty_name)
    end

    def host_line
      value = if @distro.wsl?
                "WSL2"
              end
      value ||= dmi("product_name")
      value ||= @distro.hostname
      Line.new("Host", value)
    end

    def dmi(field)
      path = "/sys/devices/virtual/dmi/id/#{field}"
      return nil unless File.readable?(path)

      value = File.read(path).strip
      value.empty? ? nil : value
    rescue SystemCallError
      nil
    end

    def kernel_line
      Line.new("Kernel", Etc.uname[:release].to_s)
    end

    def uptime_line
      seconds = File.read("/proc/uptime").split.first.to_f
      Line.new("Uptime", humanize_duration(seconds))
    rescue SystemCallError
      nil
    end

    def packages_line
      count = rpm_count
      Line.new("Packages", "#{count} (rpm)") if count
    end

    def rpm_count
      output = IO.popen(%w[rpm -qa], err: File::NULL, &:read)
      return nil unless $?.success?

      output.lines.size
    rescue Errno::ENOENT
      nil
    end

    def shell_line
      shell = Etc.getpwuid(Process.uid)&.shell || ENV["SHELL"]
      return nil if shell.nil? || shell.empty?

      Line.new("Shell", File.basename(shell))
    rescue StandardError
      nil
    end

    def cpu_line
      model = cpu_model
      return nil unless model

      cores = cpu_cores
      value = cores ? "#{model} (#{cores})" : model
      Line.new("CPU", value)
    end

    def cpu_model
      return @cpu_model if defined?(@cpu_model)

      @cpu_model = File.foreach("/proc/cpuinfo").find { |l| l.start_with?("model name") }
                       &.split(":", 2)&.last&.strip
    rescue SystemCallError
      @cpu_model = nil
    end

    def cpu_cores
      count = Dir.glob("/sys/devices/system/cpu/cpu[0-9]*").size
      count.zero? ? nil : count
    end

    def memory_line
      values = memory_values
      return nil unless values

      total, available = values
      used = total - available
      Line.new("Memory", "#{humanize_size(used * 1024)} / #{humanize_size(total * 1024)}")
    end

    def memory_values
      info = {}
      File.foreach("/proc/meminfo") do |line|
        key, value = line.split(":", 2)
        info[key] = value.strip.split.first.to_i if value
      end
      total = info["MemTotal"]
      available = info["MemAvailable"] || info["MemFree"]
      return nil unless total && available

      [total, available]
    rescue SystemCallError
      nil
    end

    def disk_line
      fields = df_root
      return nil unless fields

      used = fields[2].to_i * 1024
      total = fields[1].to_i * 1024
      Line.new("Disk (/)", "#{humanize_size(used)} / #{humanize_size(total)}")
    end

    def df_root
      output = IO.popen(%w[df -Pk /], err: File::NULL, &:read)
      return nil unless $?.success?

      line = output.lines.last
      line&.split
    rescue Errno::ENOENT
      nil
    end

    def local_ip_line
      address = Socket.ip_address_list.find do |entry|
        entry.ipv4? && !entry.ipv4_loopback? && !entry.ipv4_multicast?
      end
      Line.new("Local IP", address.ip_address) if address
    end

    def locale_line
      locale = ENV["LC_ALL"] || ENV["LANG"]
      Line.new("Locale", locale) if locale && !locale.empty?
    end

    def timezone_line
      zone = localtime_zone || system_timezone
      Line.new("Timezone", zone) if zone
    end

    def localtime_zone
      path = File.readlink("/etc/localtime")
      path[/zoneinfo\/(.+)\z/, 1]
    rescue SystemCallError
      nil
    end

    def system_timezone
      output = IO.popen(%w[timedatectl show --property=Timezone --value], err: File::NULL, &:read)
      zone = output.strip
      $?.success? && !zone.empty? ? zone : nil
    rescue Errno::ENOENT
      nil
    end

    def humanize_duration(seconds)
      seconds = seconds.to_i
      days, rest = seconds.divmod(86_400)
      hours, rest = rest.divmod(3_600)
      minutes = rest / 60

      parts = []
      parts << "#{days}d" if days.positive?
      parts << "#{hours}h" if hours.positive?
      parts << "#{minutes}m" if minutes.positive?
      parts.empty? ? "#{seconds}s" : parts.join(" ")
    end

    def humanize_size(bytes)
      units = %w[B KiB MiB GiB TiB PiB]
      size = bytes.to_f
      index = 0
      while size >= 1024 && index < units.length - 1
        size /= 1024
        index += 1
      end

      formatted = index.zero? ? size.to_i.to_s : format("%.1f", size)
      "#{formatted} #{units[index]}"
    end
  end
end
