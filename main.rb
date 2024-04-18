require 'httparty'
require 'pg'
require 'date'
require_relative 'stock_market'

def uri(params = nil)
  "https://api.polygon.io/v1/historic/quotes/#{@symbol}/#{@trade_date}?apiKey=PKLP4XEVXGIF2YR5NOQI#{params}"
end

def load(symbol, market_date)
  @symbol     = symbol
  @trade_date = market_date

  @con = nil
  begin
    @con = PG.connect :dbname => 'stock_data', :user => 'xwps'
    data = trade_data
    until data['ticks'].nil?
      process_data(data)
      offset = data['ticks'].last['t']
      data   = trade_data(offset)
    end
  rescue PG::Error => e
    puts e.message
  ensure
    @con.close if @con
  end
end

def trade_data(offset = nil)
  offset_param      = offset.nil? ? offset : "&offset=#{offset}"
  historic_data_uri = uri(offset_param)
  response          = HTTParty.get(historic_data_uri).body
  JSON.parse(response)
end

def process_data(data)
  data['ticks'].each do |ticker|
    epoch_time = ticker['t']
    price      = ticker['bP']

    next if price.nil?
    @con.exec("INSERT INTO prices (symbol, price, trade_time, trade_date) VALUES ('#{@symbol}',#{price}, '#{epoch_time}', '#{@trade_date}')")
  end
end

def simulate(symbol, market_date, positive, negative)
  StockMarket.new(symbol, market_date).run(positive, negative)
end

def clear_data_for(symbol, market_date)
  @con = nil
  begin
    @con = PG.connect :dbname => 'stock_data', :user => 'xwps'
    @con.exec("DELETE from prices where symbol = '#{symbol}' and trade_date = '#{market_date}'")
  rescue PG::Error => e
    puts e.message
  ensure
    @con.close if @con
  end
end

def load_data(symbol, days)
  days.each do |market_date|
    clear_data_for(symbol, market_date)
    load(symbol, market_date)
  end
end

def output(symbol, days)
  days.each do |market_date|
    con = nil
    db   = 'stock_data'
    user = 'xwps'

    begin
      statement = "select * from prices where symbol = '#{symbol}' AND trade_date = '#{market_date}' ORDER BY ID ASC LIMIT 1500"
      con       = PG.connect(dbname: db, user: user)
      file = File.new(market_date.to_s + '_data.txt', 'w')
      file.puts("id,price")
      prev = nil
      con.exec(statement).each do |rec|
        next if prev && prev['price'] == rec['price']

        file.puts(rec['id'] + ',' + rec['price'])
        prev = rec
      end
      file.close
    rescue PG::Error => e
      puts "Error opening connection: #{e.message}"
    ensure
      con&.close
    end
  end
end

@highest_change_properties = {
  change:   0,
  positive: 1.0,
  negative: 1.0
}

def run_analysis(days, symbol, positive, negative)
  total = 0

  days = [days] if days.is_a?(String)
  days.each do |val|
    change = simulate(symbol, val, positive, negative) #refactored
    puts "Day: #{val} & change: #{change}\n\n"
    total += (change - 1) * 100
  end

  total_change_avg = total / days.count
  puts "\nTotal change avg across #{days.count} days: #{total_change_avg}%"
  total_change_avg
end

def run_trend_spreads(days, symbol)
  trend_index = 2000
  step_value  = 0.0005

  positive_index = trend_index
  negative_index = trend_index

  positive = 1.001
  negative = 0.99

  positive_step_value = step_value
  negative_step_value = step_value

  #days.each do |val|
    while positive_index.positive?
      while negative_index.positive?
        change = run_analysis(days, symbol, positive, negative)
        if change > @highest_change_properties[:change]
          @highest_change_properties[:change]   = change
          @highest_change_properties[:positive] = positive
          @highest_change_properties[:negative] = negative
        end
        negative       += negative_step_value
        negative_index -= 1
      end
      positive       += positive_step_value
      positive_index -= 1
    end
  #end

  puts "Change properties: #{@highest_change_properties}"
end

#days = ['2019-11-6', '2019-11-7', '2019-11-8']
#days =['2019-10-14', '2019-10-15', '2019-10-16', '2019-10-17', '2019-10-18']
#days = ['2019-10-25','2019-10-28', '2019-10-29', '2019-10-30', '2019-10-31', '2019-11-1'] # 16.5%
#days = ['2019-11-6']
days = ['2019-10-29']
#run_trend_spreads(days, 'ENPH')
#load_data('ENPH', days)
puts run_analysis(days, 'ENPH', 1.001, 1) # KEEP!!! 14 trend avg count
#puts run_analysis(days, 'ENPH', 1.001, 1.00005)
#puts run_analysis(days, 'ENPH', 1.001, 0.999499)

output('ENPH',days)
#puts run_analysis(days,'ENPH',1.001, 0.9999999999999989)
