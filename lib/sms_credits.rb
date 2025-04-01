# frozen_string_literal: true

require_relative "sms_credits/version"
require_relative "sms_credits/counter"

module SmsCredits
  module_function

  # Shortcut for SmsCredits::Counter.calculate
  # that extracts **only** the number of segments.
  #
  # @param message [String] The message to be sent.
  # @return [Integer] The number of segments required for the message.
  def count(message = '')
    SmsCredits::Counter.calculate(message)[:segments]
  end
end