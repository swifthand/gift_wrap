require 'active_support/json'
require 'active_support/concern'
require 'active_support/core_ext/class/attribute'
require 'active_model/naming'
require 'active_model/serialization'
require 'active_model/serializers/json'

module GiftWrap
end

Dir[File.join(File.dirname(__FILE__), "gift_wrap", "*.rb")].each do |rb_file|
  require rb_file
end
