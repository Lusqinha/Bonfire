class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    render inertia: "Home/Index"
  end
end
