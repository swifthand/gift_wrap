require 'active_model'

module GiftWrap
end

Dir[File.join(File.dirname(__FILE__), "gift_wrap", "*.rb")].each do |rb_file|
  require rb_file
end
