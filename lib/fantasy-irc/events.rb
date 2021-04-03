require 'securerandom'

module Fantasy
    module Event
        class Factory
            def initialize
                puts "Initializing new Event::Factory #{self}"
                @events = Hash.new
            end

            def create name
                name.downcase!

                if not @events[name].nil? then
                    return @events[name]
                    # TODO: log warning
                end

                @events[name] = Event.new(name)
            end

            def by_name name
                name.downcase!

                if not @events[name] then
                    raise "Tried to access unknown event \"#{name}\" in Event::Factory \"#{self}\""
                end

                @events[name]
            end
        end

        class Event
            attr_reader :name

            def initialize(name)
                puts "New Event with name #{name}"
                @name = name
                @callbacks = Hash.new
            end

            def register(&callback)
                uuid = SecureRandom.uuid()

                @callbacks[uuid] = callback
                puts "#{self}: registered callback #{callback} with uuid #{uuid}."
            end

            def call(args=nil)
                if @callbacks.empty? then
                    return
                end

                @callbacks.each { |uuid, proc|
                    proc.call(*args)
                }
            end
        end
    end
end
