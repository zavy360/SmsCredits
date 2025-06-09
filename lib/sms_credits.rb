# frozen_string_literal: true

require_relative "sms_credits/version"
require_relative "sms_credits/counter"
require_relative "sms_credits/sanitizer"

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

  # Shortcut for SmsCredits::Sanitizer.sanitize
  #
  # @param message [String] The message to be sent.
  # @return [Integer] The number of segments required for the message.
  def sanitize(message = '')
    SmsCredits::Sanitizer.sanitize(message)[:sanitized_message]
  end

  # Gets information about the message encoding, segments, illegal characters, and sanitized characters.
  #
  # @param message [String] The message to be sent.
  # @return [Hash] A hash containing the encoding, segments, illegal characters, sanitized characters, and sanitized message.
  def info(message = '')
    result = SmsCredits::Counter.calculate(message) || {}
    sanitized_result = SmsCredits::Sanitizer.sanitize(message) || {}

    result.merge(sanitized_result)
  end
end