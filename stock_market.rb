require 'pg'
require_relative 'trade_algorithm_three'
require_relative 'trade_algorithm_four'
require_relative 'trade_data'

class StockMarket
  attr_accessor :con
  attr_reader :market_date, :symbol

  def initialize(symbol, market_date)
    @con         = nil
    @symbol      = symbol
    @market_date = market_date
  end


  def trade_data
    TradeData.single_day(symbol, market_date, nil) { |data| yield data }
  end

  def run(positive, negative)
    trader_algorithm = TradeAlgorithmThree.new(positive, negative)

    trade_data do |ticker_data|
      trader_algorithm.analyze ticker_data
    end

    trader_algorithm.finish
  end
end