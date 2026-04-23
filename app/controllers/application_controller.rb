class ApplicationController < ActionController::Base
  include Authentication
  inertia_share do
    { current_user: Current.user&.slice(:id, :email_address) }
  end
end
