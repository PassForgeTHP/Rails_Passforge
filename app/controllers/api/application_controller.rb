module Api
  class ApplicationController < ::ApplicationController
    before_action :authenticate_user!
    respond_to :json
  end
end
