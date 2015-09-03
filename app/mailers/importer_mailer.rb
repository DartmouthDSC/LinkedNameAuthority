class ImporterMailer < ApplicationMailer
  default from: 'dac.developers@cloud.dartmouth.edu'
  
  # Send email out with output from oracle import into LNA.
  def output_email(title, emails, output)
    @title = title
    @output = output
    subject = title ? "Load from #{title} to LNA" : "Load to LNA"
    mail(to: emails, subject: subject)
  end
end
