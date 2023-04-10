require "socket" # TCPSocket
require "openssl"
require "array-unique"

module Fantasy
  class IRC
    attr_reader :events, :rooms, :users, :plugins
    attr_reader :started, :session, :loggedin, :connected

    def initialize(options = {})
      $bot = self
      @data = Hash.new
      @started = Time.now.to_i
      @running = 0
      @loggedin = 0
      @connected = 0
      @prefix = options[:prefix] || "!"

      @events = Event::Factory.new
      @rooms = Room::Factory.new self
      @users = User::Factory.new self
      @plugins = Plugins.new

      %w{tick loggedin connected user_joined user_parted user_quit channel_message}.each do |e|
        @events.create(e)
      end
    end

    def login(data)
      if not data[:nickname] and data[:username]
        data[:nickname] = data[:username]
      end
      if not data[:username] and data[:nickname]
        data[:username] = data[:nickname]
      end
      if not data[:realname]
        data[:realname] = "https://rubygems.org/gems/fantasy-irc"
      end

      if not data[:nickname]
        raise "you need to specify :nickname and/or :username on login"
      end

      if data[:password]
        self.send("PASS #{data[:password]}")
      end

      self.send("USER #{data[:username]} fantasy fantasy :#{data[:realname]}")
      self.send("NICK #{data[:nickname]}")
    end

    def send(s)
      # Send a message to the server
      if not @connected
        raise "not connected to a server!"
      end

      # remove everything after a newline
      s.gsub!(/\n.*$/, "")
      puts "<-- #{s}"
      @data[:socket].puts "#{s}\n"
    end

    def connect(data)
      if not data[:server]
        raise "you need to specify :server on connect"
      end
      if not data[:ssl]
        data[:ssl] = false
      end
      if not data[:port]
        data[:port] = data[:ssl] ? 6697 : 6667
      end

      # Connect to the chat server
      @data[:socket] = @data[:realsocket] = TCPSocket.open(data[:server], data[:port])

      if !!data[:ssl]
        @data[:socket] = OpenSSL::SSL::SSLSocket.new(@data[:realsocket])
        @data[:socket].connect
      end

      @connected = Time.now.to_i
      self.events.by_name("connected").call

      return @data[:socket]
    end

    def cleanup
      puts "[!][Cleanup] Closing socket."
      @data[:socket].close()
    end

    def parse(s)
      s.chomp!

      if (s[0, 4] == "PING")
        tok = s.split(" ", 2)
        self.send "PONG #{tok[1]}"
      elsif (s[0, 1] == ":")
        # Server stuff
        tok = s.split(" ", 4)

        if (tok[1] == "001")
          # loggedin
          @loggedin = Time.now.to_i
          # ignore ourself
          self.users.create(tok[2]).ignore!
          self.events.by_name("loggedin").call
        elsif (tok[1] == "JOIN")
          # user joined
          room_name = tok[2].gsub(/^:/, "") # remove leadig : (on some networks, but not all!)
          room = self.rooms.by_name(room_name)
          user = self.users.create(tok[0][1, tok[0].length])

          # add user to room and room to user
          room.users << user
          user.rooms << room

          return if user.ignored?

          self.events.by_name("user_joined").call([room, user])
        elsif (tok[1] == "PRIVMSG")
          # channel or private message
          if (tok[2][0, 1] == "#")
            # channel message
            room = self.rooms.by_name(tok[2])
            user = self.users.create(tok[0][1, tok[0].length])

            # add user to room and room to user
            room.users << user
            user.rooms << room

            return if user.ignored?

            text = tok[3][1, tok[3].length]
            self.events.by_name("channel_message").call([room, user, text])

            if text[0] == @prefix
              command, args = text.split(" ", 2)
              self.plugins.command(command[1, command.length], { :room => room, :user => user }, args)
            end
          end
        elsif (tok[1] == "PART")
          # user parted
          room = self.rooms.by_name(tok[2])
          user = self.users.create(tok[0][1, tok[0].length])

          # remove user from room and room from user
          room.users.delete user
          user.rooms.delete room

          return if user.ignored?

          # TODO part text?
          self.events.by_name("user_parted").call([room, user])
        elsif (tok[1] == "QUIT")
          # user quit
          user = self.users.create(tok[0][1, tok[0].length])

          puts "!!! user #{user} quit."
          # remove user from all rooms
          self.rooms.all.values.each do |r|
            r.users.delete user
          end
          user.reset

          self.events.by_name("user_quit").call([user])
        else

          # puts "[!] UNKNOWN PROTOCOL PART: #{s}"
        end
      else
        puts "[!] UNKNOWN PROTOCOL PART: #{s}"
      end
    end

    def run
      if @running.nonzero?
        return false
      end

      @running = Time.now.to_i
      last_tick = @running
      last_ping = @running

      loop do
        time_now = Time.now

        # tick every second
        if time_now.to_i > last_tick
          self.events.by_name("tick").call(time_now)
          last_tick = time_now.to_i
        end

        # chatserver ping, every 5 minutes
        if @connected.nonzero? and time_now.to_i - 300 >= last_ping
          self.send("PING :" + time_now.to_f.to_s)
          last_ping = time_now.to_i
        end

        # connection
        if @connected.nonzero?
          ready = select([@data[:socket]], nil, nil, 0.1)
          next if !ready
          for s in ready[0]
            if s == @data[:socket]
              return if @data[:socket].eof # XXX?
              s = @data[:socket].gets
              puts "--> #{s}"
              self.parse(s)
            end
          end
        else # no connection, less cpu usage
          sleep(0.5)
        end
      end
    end
  end
end
