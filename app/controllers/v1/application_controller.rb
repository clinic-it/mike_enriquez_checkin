class V1::ApplicationController < ApplicationController

  skip_before_filter :authorize

end
