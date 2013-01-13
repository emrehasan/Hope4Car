class HttpRequestWorker
  include Sidekiq::Worker

  def perform(city)
    Car.parse_or_load_cars_and_update_db(city) 
  end
end