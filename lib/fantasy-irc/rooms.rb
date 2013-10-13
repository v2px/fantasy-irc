module Fantasy
    module Room
        class Factory
            def initialize connection
                puts "Initializing new Room::Factory #{self} with connection #{connection}"
                @data, @data[:rooms] = Hash.new, Hash.new
                @connection = connection
            end

            def new name
                name.downcase!

                if not @data[:rooms][name].nil? then
                    raise "We already know the room #{name}"
                end

                @data[:rooms][name] = Room.new(name, @connection)
            end

            alias :create :new

            def by_name name
                name.downcase!

                if not @data[:rooms][name] then
                    raise "Tried to access unknown room \"#{name}\" in Room::Factory \"#{self}\""
                    #TODO: log
                end

                @data[:rooms][name]
            end

            def all
                @data[:rooms]
            end
        end

        class Room
            attr_reader :name, :users

            def initialize name, connection
                if not connection.respond_to?(:send) then
                    raise "Connection class needs to be able to respond to :send"
                end

                puts "New Room #{self.object_id} with name #{name}"
                @name = name
                @joined = false
                @connection = connection
                @users = Array::Unique.new
            end

            def join
                if @joined == true then
                    raise "Already joined room #{@name}."
                end

                @connection.send("JOIN "+@name)
                @joined = true	# TODO: maybe we should set that if we get the
                # correct reply. this is for testing only! XXX
                return self
            end

            def joined?
                !!@joined
            end

            # sends a privmsg to the room
            def say message
                if @joined == false then
                    raise "Tried to talk to a room (#{name}) we're not in."
                end

                @connection.send('PRIVMSG '+@name+' :'+message)
                return self
            end

            # sends a privmsg with ACTION to the room
            def me message
                self.say "\001ACTION #{message}\001"
            end

            # sets a topic in the room
            def topic message
                if @joined == false then
                    raise "Tried to set topic in a room (#{name}) we're not in."
                end

                @connection.send('TOPIC '+@name+' :'+message)
                return self
            end

            def to_s
                "#{@name}"
            end
        end
    end
end
