require "ddate"
plugin = Plugin.new "datetime"

plugin.handle(/^date$/i) do |data|
  next data[:room].say Time.now.localtime.strftime "%a, %d %b %Y %T %z"
end

plugin.handle(/^ddate$/i) do |data|
  ddate = DDate.new
  data[:room].say "Today is #{ddate.day_of_week_name}, the #{ordinalize(ddate.day_of_month)} day of #{ddate.month} in the YOLD #{ddate.year}"
  if not ddate.holyday.nil?
    data[:room].say "Today is also a holyday. It's #{ddate.holyday}! Make sure to tell your boss."
  end
  next
end

$bot.plugins.add(plugin)

def ordinalize(number)
  if (11..13).include?(number % 100)
    "#{number}th"
  else
    case number % 10
    when 1; "#{number}st"
    when 2; "#{number}nd"
    when 3; "#{number}rd"
    else "#{number}th"
    end
  end
end
