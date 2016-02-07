#!/usr/bin/env ruby
require 'fantasy-irc'

# new connection
bot = Fantasy::IRC.new

# load some plugins
bot.plugins.load 'nettools'

# log in once we are connected
connected = Proc.new do
	bot.login nickname: "example", username: "example", realname: "GECOS field"
end
bot.events.by_name('connected').register &connected

# join a room and say hi
loggedin = Proc.new do
    bot.rooms.new("#test").join.note "ohai"
end
bot.events.by_name('loggedin').register &loggedin

# we also want to greet users that are joining the room
user_joined = Proc.new do |room, user|
	room.say("Hey, #{user.name}!")
end
bot.events.by_name('user_joined').register &user_joined

# and monitor everything they say
channel_message = Proc.new do |room, user, text|
	puts "!! #{user.name} said in room #{room.name}: #{text}"
end
bot.events.by_name('channel_message').register &channel_message

bot.connect server: "irc.example.com", ssl: true, port: 6697
bot.run
