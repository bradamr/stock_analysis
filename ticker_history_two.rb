require_relative 'modules/calculations'

class TickerHistoryTwo
  include Calculations::Percentages
  include Calculations::Stocks
  attr_reader :tickers, :trend_history

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

  TRENDING_BOUNDS = {
    positive: 1.00035,
    negative: 1.000005
  }.freeze

  # Minimum number of tickers in history to
  # create realistic trend amount.
  TICKER_HISTORY_TREND_COUNT = 6

  def initialize
    @tickers       = []
    @trend_history = []
  end

  def add(ticker_data)
    trend_history << change_from_previous(ticker_data) if tickers.count > 1
    tickers << ticker_data
  end

  def last_ticker_and_trend
    count = TICKER_HISTORY_TREND_COUNT
    puts "Last #{count} tickers: #{tickers.last(count).map { |t| t['price']}}, trend: #{trend_history.last(count)}"
  end

  def trend_type
    return TREND_TYPES[:unknown] if trend_history.count < TICKER_HISTORY_TREND_COUNT
    return TREND_TYPES[:positive] if trending_average_change >= TRENDING_BOUNDS[:positive]
    return TREND_TYPES[:negative] if trending_average_change <= TRENDING_BOUNDS[:negative]

    TREND_TYPES[:neutral] if trending_average_change > TRENDING_BOUNDS[:negative] &&
      trending_average_change < TRENDING_BOUNDS[:positive]

  end

  def trending_average_change
    return 0 if trend_history.count < TICKER_HISTORY_TREND_COUNT

    trend_history.last(TICKER_HISTORY_TREND_COUNT).reduce(:+) /
      TICKER_HISTORY_TREND_COUNT
  end

  def latest_price
    tickers.last['price']
  end

  private

  def change_from_previous(ticker_data)
    return 0 unless tickers.count > 1

    percent_change_from(latest_price, ticker_data['price'])
  end

end