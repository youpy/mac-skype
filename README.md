# mac-skype

mac-skype is a library to use Skype from Mac. It runs on Ruby 1.9 and does not depend on either RubyCocoa or AppleScript.

## Tested Rubies

* 1.8.7
* 1.9.3
* 2.0.0

## Installation

Add this line to your application's Gemfile:

    gem 'mac-skype'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mac-skype

## Usage

```ruby
require 'mac-skype'

agent = Mac::Skype::Agent.instance
agent.connect
```

### Send Skype command

```ruby
agent.send_command('PROTOCOL 9999') # //=> "PROTOCOL 8"
```

### Observe incoming messages

```ruby
agent.on_message do |message|
  puts message
end

agent.run_forever
```

### Use with Ruby4Skype API

[Ruby4Skype](http://rubydoc.info/gems/Ruby4Skype/)

```ruby
require 'mac-skype'
require 'mac-skype/Ruby4Skype'

Skype.init
Skype.attach_wait
Skype::ChatMessage.set_notify do |chatmessage, property, value|
  if property == :status and value == 'RECEIVED'
    chatmessage.get_chat.send_message chatmessage.get_body
  end
end
Skype.messageloop
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
