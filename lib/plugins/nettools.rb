plugin = Plugin.new "nettools"

plugin.handle(/^ping$/i) do |data, args|
  if args.empty?
    next data[:room].say "ping needs more arguments"
  end

  if args[0].match(/[^a-z0-9\.-]/i)
    next data[:room].say "invalid characters in argument"
  end

  Thread.new do
    ping = `/usr/bin/env ping -w 3 -c 1 -- #{args[0]} 2>&1`

    if ping.match(/unknown host (.+)/)
      data[:room].say "unknown host #{$1}"
    elsif ping.match(/^(64 bytes.+)/)
      data[:room].say "#{$1}"
    elsif ping.match(/0 received/m)
      data[:room].say "no reply :-("
    else
      data[:room].say "bogus hostname"
    end

    next
  end
end

plugin.handle(/^host$/i) do |data, args|
  if args.empty?
    next data[:room].say "host needs more arguments"
  end

  if args[0].match(/[^a-z0-9\.-]/i)
    next data[:room].say "invalid characters in argument"
  end

  Thread.new do
    host = `/usr/bin/env host #{args[0]} 2>&1`
    lines = host.split(/\n/)
    lines.take(3).each do |line|
      data[:room].say line
    end

    next
  end
end

$bot.plugins.add(plugin)
