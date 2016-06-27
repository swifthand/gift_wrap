module GiftWrap

  def self.config
    @config ||= GiftWrap::Configuration.new
  end


  def self.configure
    yield(config)
  end

end

Dir[File.join(File.dirname(__FILE__), "gift_wrap", "*.rb")].each do |rb_file|
  require rb_file
end
