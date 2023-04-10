class Magic8Ball < Plugin
  attr_reader :answers

  def initialize(name)
    super

    @answers = [
      # Positive
      "It is certain",
      "It is decidedly so",
      "Without a doubt",
      "Yes - definitely",
      "You may rely on it",
      "As I see it, yes",
      "Most likely",
      "Outlook good",
      "Yes",
      "Signs point to yes",
      # Neutral
      "Reply hazy, try again",
      "Ask again later",
      "Better not tell you now",
      "Cannot predict now",
      "Concentrate and ask again",
      # Negative
      "Don't count on it",
      "My reply is no",
      "My sources say no",
      "Outlook not so good",
      "Very doubtful",
    ]
  end
end

plugin = Magic8Ball.new "8ball"

plugin.handle(/^8ball$/i) do |data|
  data[:room].say plugin.answers.sample
end

$bot.plugins.add(plugin)
