class CarsController < ApplicationController

  # GET /cars
  # GET /cars.json
  def index
    
    
    @point = Geokit::LatLng.new(params[:latitude].to_f, params[:longitude].to_f)
    radius = params[:radius].to_i
    fuel_min = params[:fuel_min].to_i
    fuel_max = params[:fuel_max].to_i
    
######## Just for testing purposes: ###################
    radius = 10000 if params[:radius].nil?
    fuel_min = 0 if params[:fuel_min].nil?
    fuel_max = 100 if params[:fuel_max].nil?
    if params[:latitude].nil? || params[:longitude].nil?
      loc_a=Geokit::Geocoders::GoogleGeocoder.geocode 'Glasower Str. 54, Berlin, 12051'
      @point = Geokit::LatLng.new(loc_a.lat, loc_a.lng)
    end
#########################################################
    @cars = []
    Car.find(:all, :conditions => {:free => true, :fuel => fuel_min..fuel_max}).each do |car|
      if car.is_in_radius?(@point,radius) 
        @cars << car
      end
    end

    # respond_to do |format|
    #   format.html # index.html.erb
    #   format.json { render json: @cars }
    # end
  end

  # GET /cars/1
  # GET /cars/1.json
  def show
    @car = Car.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @car }
    end
  end

  # GET /cars/new
  # GET /cars/new.json
  def new
    @car = Car.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @car }
    end
  end

  # GET /cars/1/edit
  def edit
    @car = Car.find(params[:id])
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = Car.new(params[:car])

    respond_to do |format|
      if @car.save
        format.html { redirect_to @car, notice: 'Car was successfully created.' }
        format.json { render json: @car, status: :created, location: @car }
      else
        format.html { render action: "new" }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cars/1
  # PUT /cars/1.json
  def update
    @car = Car.find(params[:id])

    respond_to do |format|
      if @car.update_attributes(params[:car])
        format.html { redirect_to @car, notice: 'Car was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    @car = Car.find(params[:id])
    @car.destroy

    respond_to do |format|
      format.html { redirect_to cars_url }
      format.json { head :no_content }
    end
  end




  
end
