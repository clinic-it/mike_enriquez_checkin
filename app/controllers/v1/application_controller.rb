class V1::ApplicationController < ApplicationController

  skip_before_action :authorize

end
