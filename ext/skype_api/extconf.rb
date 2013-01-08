if RUBY_VERSION < '1.9.0'
  $LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
end

require "mkmf"

# Name your extension
extension_name = 'skype_api'

# Set your target name
dir_config(extension_name)

framework_dir = File.dirname(File.expand_path(__FILE__)) + '/../../ext/Frameworks/'

$CFLAGS += ' -F%s' % framework_dir
$LDFLAGS += ' -F%s -framework Skype -framework Foundation' % framework_dir

begin
  MACRUBY_VERSION # Only MacRuby has this constant.
  $CFLAGS += ' -fobjc-gc' # Enable MacOSX's GC for MacRuby
rescue
end

# Do the work
create_makefile(extension_name)
