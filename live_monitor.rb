require 'httparty'

class LiveMonitor
  attr_reader :delay_in_s

  def initialize(stock_symbol, delay_in_s)
    @stock_symbol = stock_symbol
    @delay_in_s = delay_in_s.to_f
  end

  def self.monitor(stock_symbol, delay_in_s)
    new(stock_symbol, delay_in_s).monitor
  end

  def stock_symbol
    @stock_symbol.upcase
  end

  def uri
    "https://api.iextrading.com/1.0/tops/last?symbols=#{stock_symbol}"
  end

  def monitor
  while (1 == 1)
    puts HTTParty.get(uri)
    sleep(delay_in_s)
  end
    end
end

LiveMonitor.monitor(ARGV[0], ARGV[1])