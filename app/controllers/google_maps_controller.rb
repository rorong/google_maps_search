# require 'googlemaps/services/places'

class GoogleMapsController < ApplicationController
  def maps
    @places = []

    total_countries = []
    total_states = []
    total_cities = []

    countries = CS.countries

    total_countries << countries.values
    total_countries.flatten!

    # countries.each do |key, value|
    #   states = CS.states(key)
    #   next if states.blank?

    #   total_states << states.values
    #   total_states.flatten!

    #   states.each do |state_code, state_value|
    #     cities = CS.cities(state_code, key)
    #     total_cities << cities

    #     next if cities.blank?

    #     total_cities.flatten!
    #   end
    # end

    @places << total_countries
    # @places << total_states
    # @places << total_cities

    @places.flatten!

    # CS.cities(state, country)
    # CS.states(country).keys.flat_map { |state| CS.cities(state, country) }

    respond_to do |format|
      format.json { render json: { places: @places } }
      format.html
    end

    filter_params = params.fetch(:filter, {})
    query_field_name = filter_params[:place]
  end

  def add_location
    @place = Place.new(place_params)

    if @place.save
      flash[:success] = "Place added!"
    end
    redirect_to root_path
  end

  def saved_locations
    @places = Place.order('created_at DESC')
  end

  def get_location
    @place = Place.find(params[:id])
  end

  private

  def place_params
    params.require(:place).permit(:title, :raw_address, :latitude, :longitude, :visited_by)
  end
end
