require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Mac::Skype

describe Agent do
  before do
    @agent = Agent.new
  end

  describe '#skype_running?' do
    its(:skype_running?) { should be_true }
  end
end
