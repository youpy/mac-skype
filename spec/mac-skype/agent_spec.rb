require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include Mac::Skype

describe Agent do
  subject do
    Agent.instance
  end

  after do
    if subject.is_a?(Agent)
      subject.disconnect
    end
  end

  it 'is singleton class' do
    lambda do
      Agent.new
    end.should raise_error

    Agent.instance.should equal(Agent.instance)
  end

  describe '#skype_running?' do
    its(:skype_running?) { should be_true }
  end

  describe '#name' do
    its(:name) { should eql('mac-skype') }
  end

  describe '#connect' do
    it 'should connect' do
      subject.should_not be_connected

      subject.connect

      subject.should be_connected
    end
  end

  describe '#disconnect' do
    before do
      subject.connect
    end

    it 'should disconnect' do
      subject.should be_connected

      subject.disconnect

      subject.should_not be_connected
    end
  end

  describe '#send_command' do
    before do
      subject.connect
    end

    it 'should send command' do
      subject.send_command('PROTOCOL 9999').should match(/^PROTOCOL \d+$/)
      subject.send_command('FOO').should eql('ERROR 2 Unknown command')
    end
  end
end
