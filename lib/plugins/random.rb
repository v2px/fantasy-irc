plugin = Plugin.new "random"

# flips a coin which can come up heads or tails
plugin.handle(/^coin$/i) do |data|
  if rand(2) == 0
    next data[:room].me "flipped a coin: Came up tails."
  else
    next data[:room].me "flipped a coin: Came up heads."
  end
end

# generates a pseudo-random number
plugin.handle(/^rand$/i) do |data, args|
  if args.empty?
    next data[:room].say rand.to_s
  else
    next data[:room].say rand(args[0].to_i).to_s
  end
end

# chooses an option from a set of option
plugin.handle(/^decide$/i) do |data, args|
  if args.empty?
    next data[:room].say "What do you want me to decide?"
  end

  next data[:room].say args.sample
end

$bot.plugins.add(plugin)
