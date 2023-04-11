module Fantasy
  class Plugins
    attr_reader :plugins

    def initialize
      @plugins = {}
    end

    def add(plugin)
      @plugins[plugin.name] = plugin
      puts "#{plugin.name} = #{plugin}"
    end

    def load(name)
      local = File.join(File.dirname($0), "plugins")
      vendor = File.join(File.dirname(__FILE__), "..", "plugins")
      [*name].each do |n|
        file = "#{n}.rb"
        local_file = File.join(local, file)
        vendor_file = File.join(vendor, file)
        if File.exists?(local_file)
          puts "[plugin] Loading #{file} (local)."
          Kernel.load local_file
        elsif File::exists?(vendor_file)
          puts "[plugin] Loading #{file} (vendor)."
          Kernel.load vendor_file
        else
          puts "[plugin] #{file} could not be found."
        end
      end
    end

    def command(command, data, args)
      if not args.nil?
        args = args.split(" ")
      else
        args = []
      end
      @plugins.values.each do |plugin|
        puts "#{plugin}"
        plugin.handle! command, data, args
      end
    end
  end
end

class Plugin
  attr_reader :name

  def initialize(name)
    @name = name
    @handlers = {}
  end

  def handle(pattern, &block)
    @handlers[pattern] = block
  end

  def handles?(command)
    @handlers.keys.each do |pattern|
      if command.match pattern
        return true
      end
    end

    return false
  end

  def handle!(command, data, args = [])
    #puts "trying to handle #{command} with #{data} and #{args}"
    @handlers.each do |pattern, block|
      if command.match(pattern)
        puts "#{block} handles #{command}"
        begin
          block.call data, args
        rescue Exception => e
          puts "#{block} failed with Exception #{e}"
          puts e.backtrace
        end

        break
      end
    end
  end
end
