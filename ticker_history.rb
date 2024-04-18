require_relative 'modules/calculations'

class TickerHistory
  include Calculations::Percentages
  include Calculations::Stocks
  attr_reader :tickers, :trend_history

  POSITIVE_TREND = :positive.freeze
  NEGATIVE_TREND = :negative.freeze
  NEUTRAL_TREND  = :neutral.freeze

  def initialize
    @tickers = []
  end

  def add(ticker_data)
    tickers << ticker_data.merge(change_from_previous(ticker_data))
  end

  def historic_trend
    average_price(tickers.last(15).map { |p| p[:change_from_previous].to_f })
  end

  def trending?
    return NEUTRAL_TREND if tickers.count < 2 || ticker_retained?
    return POSITIVE_TREND if ticker_increased?

    NEGATIVE_TREND if ticker_decreased?
  end

  def latest_price
    tickers.last['price'].to_f
  end

  def clear?
    tickers.count == 1
  end

  private

  def change_from_previous(ticker_data)
    return {} unless tickers.count >= 1

    { change_from_previous:
        percent_change_from(latest_price, ticker_data['price']) }
  end

  def ticker_increased?
    tickers.last(2).max { |a, b| price_comparator(a, b) } == tickers.last
  end

  def ticker_decreased?
    !ticker_increased?
  end

  def ticker_retained?
    latest_price == tickers.last(2).first['price'].to_f
  end

  def price_comparator(a, b)
    a['price'].to_f <=> b['price'].to_f
  end
end