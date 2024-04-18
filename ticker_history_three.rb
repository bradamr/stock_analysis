require_relative 'modules/calculations'

class TickerHistoryThree
  include Calculations::Percentages
  include Calculations::Stocks
  attr_reader :tickers, :trends

  TREND_TYPES = {
    # Price is trending upward
    positive: :positive,
    # Price is trending downward
    negative: :negative,
    # When price is fluctuating near similar values
    neutral: :neutral,
    # Not used a lot but for when insufficient data
    unknown: :unknown
  }.freeze

  MINIMUM_TRENDS_FOR_AVERAGE = 14 # default: 10
  PRICE_DECREASE_THRESHOLD = 0.9975

   # TREND_AVERAGES = {
   #   positive: 1.005,
   #   negative: 1.0025
   #
   # }.freeze

  def initialize(positive, negative)
    @tickers = []
    @trends  = []

    @positive_trend_avg = positive.to_f
    @negative_trend_avg = negative.to_f
  end

  def positive_trend_average
    @positive_trend_avg
  end

  def negative_trend_average
    @negative_trend_avg
  end

  def add(ticker_data)
    purge_data if tickers.count > 100

    tickers << ticker_data
    trends << change_from_previous(ticker_data) if tickers.count > 1
  end

  def purge_data
    @tickers -= tickers.first(90)
    @trends -= trends.first(85)
  end

  def latest_ticker_price_increase?
    return false if tickers.count < 2

    latest_ticker_price > tickers.last(2).first['price'].to_f
  end

  def latest_ticker_price_decrease?
    return false if tickers.count < 2

    latest_ticker_price < tickers[-2]['price'].to_f
  end

  def latest_price_past_threshold?
    return false if tickers.count < 2

    (latest_ticker_price / tickers[-2]['price'].to_f) < PRICE_DECREASE_THRESHOLD
  end

  def recent_positive_trend?
    return TREND_TYPES[:unknown] if trends.count < MINIMUM_TRENDS_FOR_AVERAGE

    recent_trend >= positive_trend_average
  end

  def recent_negative_trend?
    return TREND_TYPES[:unknown] if trends.count < MINIMUM_TRENDS_FOR_AVERAGE

    recent_trend <= negative_trend_average
  end

  def trend_unknown?
    trends.count < MINIMUM_TRENDS_FOR_AVERAGE
  end

  def recent_trend
    return TREND_TYPES[:unknown] if trends.count < MINIMUM_TRENDS_FOR_AVERAGE

    trends.last(MINIMUM_TRENDS_FOR_AVERAGE).reduce(:+) / MINIMUM_TRENDS_FOR_AVERAGE
  end

  def latest_ticker_price
    tickers.last['price'].to_f if tickers.count > 0
  end

  def latest_ticker_id
    tickers.last['id']
  end

  def latest_historical_ticker_price
    tickers[-2]['price'].to_f
  end

  private

  def change_from_previous(ticker_data)
    return 0 unless tickers.count > 1

    percent_change_from(ticker_data['price'], latest_historical_ticker_price)
  end

end