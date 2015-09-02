class ImporterMailer < ApplicationMailer
  default from: 'dac.developers@cloud.dartmouth.edu'
  
  # Send email out with output from oracle import into LNA.
  def output_email(emails, output)
    @output = output
    mail(to: emails, subject: 'Output of load from Oracle to Lna')
  end
end
