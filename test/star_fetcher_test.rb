# frozen_string_literal: true

require_relative "test_helper"

class StarFetcherTest < Minitest::Test
  def distro(id:, name:, version: "", id_like: "suse opensuse")
    StarFetcher::Distro.new(
      StarFetcher::OsRelease.new(
        id: id, id_like: id_like, name: name, pretty_name: name, version_id: version
      )
    )
  end

  # -- Distro -----------------------------------------------------------------

  def test_parse_os_release
    file = Tempfile.new("os-release")
    file.write(<<~CONF)
      NAME="openSUSE Leap"
      ID="opensuse-leap"
      ID_LIKE="suse opensuse"
      PRETTY_NAME="openSUSE Leap 16.0"
      VERSION_ID="16.0"
    CONF
    file.close

    os = StarFetcher::Distro.parse_os_release(file.path)
    assert_equal "opensuse-leap", os.id
    assert_equal "suse opensuse", os.id_like
    assert_equal "openSUSE Leap 16.0", os.pretty_name
    assert_equal "16.0", os.version_id
  ensure
    file&.unlink
  end

  def test_suse_detection
    assert distro(id: "opensuse-leap", name: "openSUSE Leap").suse?
    assert distro(id: "opensuse-tumbleweed", name: "openSUSE Tumbleweed").suse?
    refute distro(id: "debian", name: "Debian", id_like: "debian").suse?
  end

  def test_logo_selection
    assert_equal "opensuse_leap", distro(id: "opensuse-leap", name: "openSUSE Leap", version: "16.0").logo_name
    assert_equal "opensuse_tumbleweed", distro(id: "opensuse-tumbleweed", name: "openSUSE Tumbleweed", version: "20260101").logo_name
    assert_equal "opensuse_microos", distro(id: "opensuse-microos", name: "openSUSE MicroOS").logo_name
    assert_equal "opensuse", distro(id: "opensuse-slowroll", name: "openSUSE Slowroll").logo_name
  end

  def test_gradient_has_two_colors
    from, to = distro(id: "opensuse-leap", name: "openSUSE Leap").gradient
    assert_equal 3, from.length
    assert_equal 3, to.length
  end

  # -- Logo -------------------------------------------------------------------

  def test_available_logos
    available = StarFetcher::Logo.available
    assert_includes available, "opensuse_leap"
    assert_includes available, "opensuse_tumbleweed"
    assert_includes available, "opensuse_microos"
  end

  def test_logo_loads_lines
    logo = StarFetcher::Logo.new("opensuse_leap")
    refute_empty logo.lines
    refute logo.lines.last.empty?
  end

  def test_logo_falls_back_for_unknown_name
    logo = StarFetcher::Logo.new("does-not-exist")
    assert_equal StarFetcher::Logo.new("opensuse").lines, logo.lines
  end

  # -- Theme ------------------------------------------------------------------

  def test_theme_disabled_is_plain
    theme = StarFetcher::Theme.new(enabled: false)
    assert_equal "hello", theme.paint("hello", rgb: [1, 2, 3], bold: true)
    assert_equal "hi", theme.gradient("hi", from: [0, 0, 0], to: [1, 1, 1])
  end

  def test_theme_enabled_wraps_ansi
    theme = StarFetcher::Theme.new(enabled: true)
    assert_includes theme.paint("hello", rgb: [1, 2, 3]), "\e[38;2;1;2;3m"
    assert_includes theme.gradient("ab", from: [0, 0, 0], to: [255, 255, 255]), "\e["
  end

  # -- Modules ----------------------------------------------------------------

  def test_modules_include_os_line
    d = distro(id: "opensuse-leap", name: "openSUSE Leap", version: "16.0")
    lines = StarFetcher::Modules.new(d).lines
    os = lines.find { |line| line.label == "OS" }
    refute_nil os
    assert_equal "openSUSE Leap", os.value
  end

  # -- Render -----------------------------------------------------------------

  def test_render_contains_header_and_info
    d = distro(id: "opensuse-leap", name: "openSUSE Leap")
    lines = [StarFetcher::Modules::Line.new("OS", "openSUSE Leap 16.0")]
    output = StarFetcher::Render.new(
      theme: StarFetcher::Theme.new(enabled: false),
      distro: d,
      logo: StarFetcher::Logo.new("opensuse_leap"),
      lines: lines
    ).to_s
    assert_includes output, "@"
    assert_includes output, "OS: openSUSE Leap 16.0"
  end

  # -- CLI --------------------------------------------------------------------

  def run_cli(*argv)
    out = StringIO.new
    previous_stderr = $stderr
    $stderr = StringIO.new
    code = StarFetcher::CLI.run(argv, stdout: out)
    [code, out.string]
  ensure
    $stderr = previous_stderr
  end

  def test_cli_version
    code, output = run_cli("--version")
    assert_equal 0, code
    assert_equal "star-fetcher #{StarFetcher::VERSION}", output.strip
  end

  def test_cli_help
    code, output = run_cli("--help")
    assert_equal 0, code
    assert_includes output, "Usage: star-fetcher"
  end

  def test_cli_list_logos
    code, output = run_cli("--list-logos")
    assert_equal 0, code
    assert_includes output.split("\n"), "opensuse_leap"
  end

  def test_cli_invalid_option
    code, = run_cli("--definitely-not-an-option")
    assert_equal 1, code
  end
end
