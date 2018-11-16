class WeeklySummaryMailer < ApplicationMailer

  START_OF_THE_WEEK = Date.today.at_beginning_of_week.strftime '%m/%d/%Y'
  END_OF_THE_WEEK = (Date.today + 2.days).strftime '%m/%d/%Y'



  def send_weekly_summary
    subject = "Weekly Summary (#{START_OF_THE_WEEK} - #{END_OF_THE_WEEK})"
    attachments.inline["#{subject}.pdf"] =
      WickedPdf.new.pdf_from_string(
        render_to_string(
          :pdf => "#{subject}.pdf", :template => 'summary/weekly_summary.haml'
        )
      )

    mail :to => ENV['summary_recipient'], :subject => subject
  end

end
