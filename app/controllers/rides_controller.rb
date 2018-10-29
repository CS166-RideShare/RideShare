class RidesController < ApplicationController

  def new_request
    respond_to do |format|
      format.html
      format.js
    end
  end
end
