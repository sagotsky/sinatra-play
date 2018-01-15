# wraps a tiny amount of /usr/bin/convert
class MagickWrapper
  def initialize(file)
    @file = file
    @cli_opts = {}
  end

  # can't use kwargs - dh is stuck on 1.9
  def resize(width)
    @cli_opts[:geometry] = "#{width}x"
    self
  end

  def write(output)
    opts = @cli_opts.each_with_object('') do |(k, v), opts|
      opts << "-#{k} #{v}"
    end

    cmd = "convert #{opts} #{@file} #{output}"

    system(cmd)
  end
end

