require "spec_helper"

describe Fantasy::IRC do
  before :each do
    @bot = Fantasy::IRC.new

    # stub the send ethod
    @bot.stub(:send) { }
  end

  describe "#new" do
    it "takes no parameter and returns a Fantasy::IRC object" do
      @bot.should be_an_instance_of Fantasy::IRC
    end
  end

  describe "login" do
    it "takes no arguments and raises an error" do
      expect { @bot.login }.to raise_error
    end

    it "takes a nickname as argument and proceeds to log in" do
      @bot.should_receive(:send).with(/^USER rspec_nick /)
      @bot.should_receive(:send).with(/^NICK rspec_nick$/)
      @bot.login(:nickname => "rspec_nick")
    end

    it "takes a username as argument and proceeds to log in" do
      @bot.should_receive(:send).with(/^USER rspec_uname /)
      @bot.should_receive(:send).with(/^NICK rspec_uname$/)
      @bot.login(:username => "rspec_uname")
    end

    it "takes a username and a nickname as argument and proceeds to log in with both" do
      @bot.should_receive(:send).with(/^USER rspec_uname /)
      @bot.should_receive(:send).with(/^NICK rspec_nick$/)
      @bot.login(:username => "rspec_uname", :nickname => "rspec_nick")
    end

    it "takes a (username and a) realname and sets the realname too" do
      @bot.should_receive(:send).with(/^USER rspec_uname [^:]+:rspec realname$/)
      @bot.login(:username => "rspec_uname", :realname => "rspec realname")
    end
  end

  describe "connect" do
    it "takes no arguments and raises an error" do
      expect { @bot.connect }.to raise_error
    end
  end

  describe "parse" do
    it "parses at least the PING message" do
      @bot.should_receive(:send).with(/^PONG :rspec_test$/)
      @bot.parse("PING :rspec_test")
    end
  end
end
