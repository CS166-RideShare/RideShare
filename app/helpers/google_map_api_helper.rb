require 'open-uri'
require 'json'

module GoogleMapApiHelper

  def direction_if_pickup(riderequest, drive_starting_id, drive_destination_id, org_duration)
    request_starting_id = riderequest.starting_id
    request_destination_id = riderequest.destination_id

    # Parse the string url into a valid URI
    url = URI.parse(
      "https://maps.googleapis.com/maps/api/directions/json?" +
      "origin=place_id:#{drive_starting_id}&destination=place_id:#{drive_destination_id}&
      waypoints=via:place_id:#{request_starting_id}|via:place_id:#{request_destination_id}&
      key=AIzaSyBB0imXtZ5Rr0x4A57NO4Un665BEQCpCoU"
    )
    # Open the URI just like you were doing
    response = open(url).read
    # Parse the string response in JSON format
    result = JSON.parse(response)
    puts result

    # Extract the duration in seconds
    duration = result[:routes].first[:legs].inject(0) {|sum, leg| sum+leg[:duration][:value]}

    # Return the response as a json if the duration increase is equal to or less than 330 seconds
    duration>org_duration+330 ? nil : response
  end
end
