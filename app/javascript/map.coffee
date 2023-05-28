markersArray = []

lat_field = $('#place_latitude')
lng_field = $('#place_longitude')

window.initMap = ->
  if $('#map').size() > 0
    map = new google.maps.Map document.getElementById('map'), {
          center: { lat: 20.593684, lng: 78.96288 },
          zoom: 5
        }

    $("#select-place").change ->
      console.log("changin", $(this).val());
      getAreaDetails($('#select-place').val());


placeMarkerAndPanTo = (latLng, map) ->
  markersArray.pop().setMap(null) while(markersArray.length)
  marker = new google.maps.Marker
    position: latLng
    map: map

  map.panTo latLng
  markersArray.push marker

highlight_area = (map, bounds) ->
  northEast = bounds.northeast;
  southWest = bounds.southwest;

  northeastLatBounds = northEast.lat;
  northeastLongBounds = northEast.lng;
  southwestlatBounds = southWest.lat;
  southwestLongBounds = southWest.lng;

  newCenter = new google.maps.LatLng(northeastLatBounds, northeastLongBounds);
  map.setCenter(newCenter);
  map.setZoom(4);

  northeastBound = new google.maps.LatLng(northeastLatBounds, northeastLongBounds);
  southwestBound = new google.maps.LatLng(southwestlatBounds, southwestLongBounds);

  rectangle = new google.maps.Rectangle({
    bounds: new google.maps.LatLngBounds(southwestBound, northeastBound),
    strokeColor: "#FF0000",
    strokeOpacity: 0.8,
    strokeWeight: 2,
    fillColor: "#FF0000",
    fillOpacity: 0.35,
    zIndex: 9999
  });

  rectangle.setMap(map);

getAreaDetails = (place_name) ->
  map = new google.maps.Map document.getElementById('map'), {
          center: { lat: -33.5781409, lng: 151.3430209 },
          zoom: 4
        }
  service = new google.maps.places.PlacesService(map);
  console.log('aaaaaaaaaa',place_name);
  
  apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json'
  apiKey = 'AIzaSyAYgz93to_KfefAj2f2T85hwqVdPWgr1m0'

  $.ajax
    url: apiUrl
    method: 'GET'
    dataType: 'json'
    data:
      address: place_name,
      key: apiKey
    success: (data) ->
      # Handle the success response
      console.log(data.results[0]);
      bounds = data.results[0].geometry.bounds;
      #northeastBounds = bounds.northeast;
      #southwestBounds = bounds.southwest;

      #bounds = new google.maps.LatLngBounds(southwestBounds, northeastBounds)
      console.log("new bounds", bounds);
      highlight_area(map, bounds)
    error: (xhr, status, error) ->
      # Handle any errors
      console.error(error)
