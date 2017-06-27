class SummaryController < ApplicationController

  require 'rmagick'

  def show
    @today = Checkin.last
    @yesterday = Checkin.offset(1).last

    @chart_data = [
      {:name => 'Yesterday', :data => @yesterday.users_with_checkin.map{|user| [user.username, user.previous_load]} },
      {:name => 'Today', :data => @today.users_with_checkin.map{|user| [user.username, user.current_load]} }
    ]
  end

  def summary_checkin
    @checkin = Checkin.last
    respond_to do |format|
      format.html
      format.jpg {
        render(
          :pdf => @checkin.checkin_date.to_s,
          :save_to_file => Rails.root.join('tmp', "#{@checkin.checkin_date.to_s}"),
          :save_only => true
        )
        pdf_file_name = Rails.root.join('tmp', "#{@checkin.checkin_date.to_s}")
        original_pdf = File.open(pdf_file_name, 'rb').read

        image = Magick::Image::from_blob(original_pdf) do
          self.format = 'PDF'
          self.quality = 100
          self.density = 144
        end
        image[0].format = 'JPG'
        image[0].to_blob

        image[0].write(Rails.root.join('tmp', "#{@checkin.checkin_date.to_s}.jpg"))
        send_file Rails.root.join('tmp', "#{@checkin.checkin_date.to_s}.jpg"), type: "image/gif", disposition: "inline"
      }
    end

  end
end
