# require 'googlemaps/services/places'

class GoogleMapsController < ApplicationController
  def maps
    # places = []
    @countries = CS.countries
    # places << countries
    # countries.each do |country|

    # end
    # CS.cities(state, country)
    # CS.states(country).keys.flat_map { |state| CS.cities(state, country) }

    respond_to do |format|
      format.json { render json: { countries: @countries } }
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
