class WeeklySummaryMailer < ApplicationMailer

  def send_weekly_summary tasks_completed
    @start_of_the_week = Date.today.at_beginning_of_week
    @end_of_the_week = Date.today
    @start_of_the_week_formatted = @start_of_the_week.strftime '%m/%d/%Y'
    @end_of_the_week_formatted = @end_of_the_week.strftime '%m/%d/%Y'
    @tasks_completed = tasks_completed
    subject =
      "Weekly Summary (#{@start_of_the_week_formatted} - " \
      "#{@end_of_the_week_formatted})"
    attachments.inline["#{subject}.pdf"] =
      WickedPdf.new.pdf_from_string(
        render_to_string(
          :pdf => "#{subject}.pdf", :template => 'summary/weekly_summary.haml'
        )
      )

    mail :to => ENV['summary_recipient'], :subject => subject
  end

end
