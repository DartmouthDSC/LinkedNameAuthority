class ImporterMailer < ApplicationMailer
  default from: 'dac.developers@cloud.dartmouth.edu'
  
  # Send email out with output from oracle import into LNA.
  def output_email(title, emails, output)
    @title = title
    @output = output
    subject = title ? "Import from #{title} to LNA" : "Import to LNA"
    mail(to: emails, subject: subject)
  end
end
