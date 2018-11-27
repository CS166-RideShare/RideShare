require 'open-uri'
require 'json'

module GoogleMapApiHelper

  def direction_if_pickup_coor(riderequest, drive_params)
    rs_lat = riderequest.starting_lat
    rs_lng = riderequest.starting_lng
    rd_lat = riderequest.destination_lat
    rd_lng = riderequest.destination_lng

    ds_lat = drive_params[:starting_lat]
    ds_lng = drive_params[:starting_lng]
    dd_lat = drive_params[:destination_lat]
    dd_lng = drive_params[:destination_lng]

    org_duration = drive_params[:duration].to_i

    waypoints = check_way_points(
      rs_lat: rs_lat,
      rs_lng: rs_lng,
      rd_lat: rd_lat,
      rd_lng: rd_lng,
      ds_lat: ds_lat,
      ds_lng: ds_lng,
      dd_lat: dd_lat,
      dd_lng: dd_lng,
    )

    place_id_url = "https://maps.googleapis.com/maps/api/directions/json?"+
                   "origin=#{ds_lat},#{ds_lng}&destination=#{dd_lat},#{dd_lng}&"+
                   waypoints+"key=AIzaSyBB0imXtZ5Rr0x4A57NO4Un665BEQCpCoU"

    # Parse the string url into a valid URI
    url = URI.parse(place_id_url)
    # Open the URI just like you were doing
    response = open(url).read
    # Parse the string response in JSON format
    result = JSON.parse(response)

    if result["routes"].empty?
      return nil
    end

    # Extract the duration in seconds
    duration = result["routes"].first["legs"].inject(0) {|sum, leg| sum+leg["duration"]["value"]}

    # Return the response as a json if the duration increase is equal to or less than 330 seconds
    # duration>org_duration+330 ? nil : response
    response
  end

  protected
    def check_way_points(args={})
      waypoints = ""
      if args[:rs_lat]!=args[:ds_lat]&&args[:rs_lng]!=args[:ds_lng]
        waypoints += "#{args[:rs_lat]},#{args[:rs_lng]}|"
      end
      if args[:rd_lat]!=args[:dd_lat]&&args[:ds_lng]!=args[:dd_lng]
        waypoints += "#{args[:rd_lat]},#{args[:rd_lng]}|"
      end
      if !waypoints.empty?
        waypoints = "waypoints="+waypoints[0..-2]+"&"
      end
      return waypoints
    end

    def adjust_json result
      bounds = result["routes"].first["bounds"]
      new_bounds = {
        "l" => {"j" => bounds["southwest"]["lat"], "l" => bounds["northeast"]["lat"]},
        "j" => {"j" => bounds["southwest"]["lng"], "l" => bounds["northeast"]["lng"]}
      }
      result["routes"].first["bounds"] = new_bounds
    end
end
