require 'open-uri'
require 'json'

module GoogleMapApiHelper

  def direction_if_pickup(riderequest, drive_starting_id, drive_destination_id, org_duration)
    request_starting_id = riderequest.starting_id
    request_destination_id = riderequest.destination_id

    waypoints = check_way_points request_starting_id, request_destination_id, drive_starting_id, drive_destination_id

    place_id_url = "https://maps.googleapis.com/maps/api/directions/json?"+
                   "origin=place_id:#{drive_starting_id}&destination=place_id:#{drive_destination_id}&"+
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
    duration>org_duration+330 ? nil : response
  end

  protected
    def check_way_points(request_starting_id, request_destination_id, drive_starting_id, drive_destination_id)
      waypoints = ""
      if request_starting_id!=drive_starting_id
        waypoints += "via:place_id:#{request_starting_id}|"
      end
      if request_destination_id!=drive_destination_id
        waypoints += "via:place_id:#{request_destination_id}|"
      end
      if !waypoints.empty?
        waypoints = "waypoints="+waypoints[0..-2]+"&"
      end
      return waypoints
    end
end
