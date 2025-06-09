module SmsCredits
  module Sanitizer
    module_function

    GSM_7BIT_CHARACTER_LOOKALIKES = {
      '–' => '-', # en dash
      '—' => '-', # em dash
      '‘' => "'", # left single quotation mark
      '’' => "'", # right single quotation mark
      '“' => '"', # left double quotation mark
      '”' => '"', # right double quotation mark
      '…' => '...', # ellipsis
      '°' => 'o', # degree symbol
      '©' => '(c)', # copyright symbol
      '®' => '(r)', # registered trademark symbol
      '™' => '(tm)', # trademark symbol
      '€' => 'EUR', # euro sign
      '•' => '*', # bullet point
      '»' => '>>', # right-pointing double angle quotation mark
      '«' => '<<', # left-pointing double angle quotation mark
    }.freeze

    # Sanitize a message by replacing lookalike characters with their GSM-7 equivalents
    # to avoid overcharging for SMS segments.
    #
    # @param [String] message The message to be sanitized.
    # @return [Hash] A hash containing the original message, sanitized message, illegal characters, and sanitized characters.
    def self.sanitize(message)
      return message unless message.is_a?(String)
      sanitized_message = message.dup

      result = {}
      result.merge!(original: message)
      result.merge!(illegal_characters: [])
      result.merge!(sanitized_characters: [])

      sanitized_message.each_char do |char|
        next if SmsCredits::Counter::GSM_7BIT_CHARACTERS.include?(char)
        result[:illegal_characters] << char
      end

      GSM_7BIT_CHARACTER_LOOKALIKES.each do |lookalike, replacement|
        next unless sanitized_message.include?(lookalike)
        sanitized_message.gsub!(lookalike, replacement)
        result[:illegal_characters] -= [lookalike]
        result[:sanitized_characters] << lookalike
      end
      result.merge!(sanitized_message: sanitized_message)
      result
    end
  end
end
