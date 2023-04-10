require "json"
require "open-uri"
require "timeout"

class HackerSays < Plugin
  def initialize(name)
    super
    self.handle(/^hackersays$/i) do |data|
      begin
        Timeout::timeout(2) {
          say_quote(data[:room])
        }
      rescue Timeout::Error
        data[:room].say("Request to hackersays.com timed out.")
      end
    end
  end

  def say_quote(room)
    quote = get_quote()
    if quote.nil?
      room.say "Could not fetch a quote. :-("
    else
      room.say "\u{201C}#{quote["c"]}\u{201D} \u{2014} \002#{quote["a"]}\002 \00315[Quote \##{quote["id"]}]\003"
    end
  end

  private

  def get_quote
    return JSON::load(open("http://hackersays.com/quote").read)
  end
end

plugin = HackerSays.new "hackersays"
$bot.plugins.add(plugin)
