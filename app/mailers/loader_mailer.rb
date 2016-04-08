class LoaderMailer < ApplicationMailer
  default from: 'dac.developers@cloud.dartmouth.edu'
  
  # Send email out with output from oracle import into LNA.
  #
  # @param title [String] title of load
  # @param emails [Array<String>] list of emails to send message to
  # @param output [Hash<Symbol, Array<String>] hash with warnings and errors
  def output_email(title, emails, output)
    @title = title ? "LNA Load: #{title}" : "LNA Load"
    @output = output
    mail(to: emails, subject: @title)
  end
end
