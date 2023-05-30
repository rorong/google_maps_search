markersArray = []

lat_field = $('#place_latitude')
lng_field = $('#place_longitude')

window.initMap = ->
  if $('#map').size() > 0
    map = new google.maps.Map document.getElementById('map'), {
          center: { lat: 20.593684, lng: 78.96288 },
          zoom: 5
        }
    drawArea(map);

    map.addListener 'click', (e) ->
      console.log(e.latLng)
      console.log(map.center)
      placeMarkerAndPanTo e.latLng, map

    $("#select-place").change ->
      console.log("changin", $(this).val());
      getAreaDetails($('#select-place').val());

drawArea = (map) ->
  drawingManager = new google.maps.drawing.DrawingManager({
    drawingMode: google.maps.drawing.OverlayType.POLYGON,
    drawingControl: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: [google.maps.drawing.OverlayType.POLYGON]
    }
  });

  drawingManager.setMap(map);

  google.maps.event.addListener drawingManager, 'overlaycomplete', (event) ->
    if event.type == 'polygon'
      polygon = event.overlay

      polygonCoordinates = []
      polygon.getPath().forEach (point) ->
        polygonCoordinates.push
          lat: point.lat()
          lng: point.lng()
        return

      console.log polygonCoordinates

placeMarkerAndPanTo = (latLng, map) ->
  markersArray.pop().setMap(null) while(markersArray.length)
  marker = new google.maps.Marker
    position: latLng,
    animation: google.maps.Animation.DROP,
    map: map,
    draggable: true

  map.panTo latLng
  markersArray.push marker

highlight_area = (map, bounds) ->
  northEast = bounds.northeast;
  southWest = bounds.southwest;

  northWest = new google.maps.LatLng(northEast.lat, southWest.lng);
  southEast = new google.maps.LatLng(southWest.lat, northEast.lng);
  northeastLatBounds = northEast.lat;
  northeastLongBounds = northEast.lng;
  southwestlatBounds = southWest.lat;
  southwestLongBounds = southWest.lng;

  northwestLatBounds = northWest.lat();
  northwestLongBounds = northWest.lng()
  southEastLatBounds = southEast.lat();
  southEastLongBounds = southEast.lng()

  b1 = new google.maps.LatLng(northeastLatBounds, northeastLongBounds);
  b2 = new google.maps.LatLng(southwestlatBounds, southwestLongBounds);
  
  new_bounds = new google.maps.LatLngBounds()

  new_bounds.extend(new google.maps.LatLng(northeastLatBounds, northeastLongBounds))
  new_bounds.extend(new google.maps.LatLng(southwestlatBounds, southwestLongBounds))
  new_bounds.extend(new google.maps.LatLng(northWest.lat(), northWest.lng()))
  new_bounds.extend(new google.maps.LatLng(southEast.lat(), southEast.lng()))
  
  center = new_bounds.getCenter()
  coordinates = []
  radius = google.maps.geometry.spherical.computeDistanceBetween(center, new_bounds.getNorthEast());

  angle = -60
  while angle < 270
    coordinates.push google.maps.geometry.spherical.computeOffset(center, radius, angle)
    angle += 60

  console.log("CAOORDINATES", coordinates);


  map.setZoom(4);
  map.setCenter(center);
  map.fitBounds(new_bounds);
  placeMarkerAndPanTo(center, map)

  distance = 10000

  nearbyBounds = new google.maps.LatLngBounds(
    google.maps.geometry.spherical.computeOffset(center, distance, 45),
    google.maps.geometry.spherical.computeOffset(center, distance, 225)
  );

  b3 = new google.maps.LatLng(northwestLatBounds, northwestLongBounds);

  b4 = new google.maps.LatLng(southEastLatBounds, southEastLongBounds);

  polygonCoords = [
    b1,
    b3,
    b2,
    b4
  ];

  polygon = new google.maps.Polygon({
    paths: coordinates,
    strokeColor: '#FF0000',
    strokeOpacity: 0.8,
    strokeWeight: 2,
    fillColor: '#FF0000',
    fillOpacity: 0.35,
    editable: true
  });

  polygon.setMap(map);

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
      console.log(data.results[0]);
      response = data.results[0]
      bounds = response.geometry.bounds;
      request = {
        placeId: "#{response.place_id}"
      };

      service.getDetails request, (place, status) ->
        if (status == google.maps.places.PlacesServiceStatus.OK)
          polygon = place.geometry.viewport;
          area = google.maps.geometry.spherical.computeArea(polygon)
          console.log('Area covered by the place: ' + area + ' square meters');

      #northeastBounds = bounds.northeast;
      #southwestBounds = bounds.southwest;

      #bounds = new google.maps.LatLngBounds(southwestBounds, northeastBounds)
      console.log("initial bounds", bounds);
      highlight_area(map, bounds)
    error: (xhr, status, error) ->
      # Handle any errors
      console.error(error)
