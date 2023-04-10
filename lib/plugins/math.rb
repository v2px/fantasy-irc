plugin = Plugin.new "math"

# flips a coin which can come up heads or tails
plugin.handle(/^pi$/i) do |data|
  next data[:room].say "\u{03C0} = #{Math::PI}"
end

plugin.handle(/^calc$/i) do |data, args|
  args_string = args.join(" ")

  args_string.gsub!(/log/, "\000")
  args_string.gsub!(/sqrt/, "\001")
  args_string.gsub!(/\^/, "**")
  args_string.gsub!(/,/, ".")

  if not args_string.match(/^[ 0-9+*\/\.()\-\000\001]+$/)
    next data[:room].say "Could not parse string."
  end

  begin
    result = Kernel.eval(args_string)
  rescue Exception => e
    next data[:room].say "#{e.to_s}"
  end

  if result.nil?
    next data[:room].say "undef"
  elsif result == 42
    next data[:room].say "the Answer to the Ultimate Question of Life, The Universe, and Everything"
  else
    next data[:room].say result.to_s
  end
end

$bot.plugins.add(plugin)
