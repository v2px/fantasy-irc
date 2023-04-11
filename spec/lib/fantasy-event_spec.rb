require "spec_helper"

describe Fantasy::Event do
  describe Fantasy::Event::Event do
    describe "#new" do
      it "takes a name as arument and returns a Fantasy::Event::Event object" do
        e = Fantasy::Event::Event.new("rspec_event")
        e.should be_an_instance_of Fantasy::Event::Event
      end
    end
  end

  describe Fantasy::Event::Factory do
    before :each do
      @fac = Fantasy::Event::Factory.new
    end

    describe "#new" do
      it "takes no arguments and returns a Fantasy::Event::Factory object" do
        @fac.should be_an_instance_of Fantasy::Event::Factory
      end
    end

    describe "create" do
      it "takes a name as arument, creates a new event with this name in lowercase and returns it" do
        event = @fac.create("rspec_event")
        event.should be_an_instance_of Fantasy::Event::Event
      end
    end
  end
end
