class LoaderMailer < ApplicationMailer
  default from: 'dac.developers@cloud.dartmouth.edu'
  
  # Send email out with output from oracle import into LNA.
  def output_email(title, emails, output)
    @title = title ? "LNA Load: #{title}" : "LNA Load"
    @output = output
    mail(to: emails, subject: @title)
  end
end
