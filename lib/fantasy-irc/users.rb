module Fantasy
  module User
    class Factory
      def initialize(connection)
        puts "Initializing new User::Factory #{self} with connection #{connection}"
        @data = Hash.new
        @data[:users] = Hash.new
        @connection = connection
      end

      def new(name)
        name = name.split(/!/, 2)[0] # remove mask
        name_lc = name.downcase

        if not @data[:users][name_lc].nil?
          return @data[:users][name_lc]
          # TODO: log! not raise
          # raise "We already know the user #{name}"
        end

        @data[:users][name_lc] = User.new(name, @connection)
      end

      alias :create :new

      def by_name(name)
        name.downcase!

        if not @data[:users][name]
          raise "Tried to access unknown user \"#{name}\" in User::Factory \"#{self}\""
        end

        @data[:users][name]
      end
    end

    class User
      attr_reader :name, :mask
      attr_accessor :rooms

      def initialize(name, connection)
        if not connection.respond_to?(:send)
          raise "Connection class needs to be able to respond to :send"
        end

        @name = name
        puts "New User #{self.object_id} with name #{@name}"
        @connection = connection
        @rooms = Array::Unique.new
        @ignored = false
      end

      # resets user information
      def reset
        puts "Resetting user #{self.object_id} with name #{@name}"
        @rooms = Array::Unique.new
      end

      def say(message)
        @connection.send("PRIVMSG " + @name + " :" + message)
        return self
      end

      def login
        self.name
      end

      # ===================
      # Ignoring
      def ignore!
        @ignored = true
      end

      def unignore!
        @ignored = false
      end

      def ignored?
        !!@ignored
      end

      # ===================

      def to_s
        "#{@name}"
      end
    end
  end
end
