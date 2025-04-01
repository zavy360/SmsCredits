module SmsCredits
  class Counter
    # GSM 7-bit basic character set
    GSM_7BIT_CHARACTERS = [
      '@', '£', '$', '¥', 'è', 'é', 'ù', 'ì', 'ò', 'Ç', "\n", 'Ø', 'ø', "\r", 'Å', 'å',
      'Δ', '_', 'Φ', 'Γ', 'Λ', 'Ω', 'Π', 'Ψ', 'Σ', 'Θ', 'Ξ', 'Æ', 'æ', 'ß', 'É',
      ' ', '!', '"', '#', '¤', '%', '&', "'", '(', ')', '*', '+', ',', '-', '.', '/',
      '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':', ';', '<', '=', '>', '?',
      '¡', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
      'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Ä', 'Ö', 'Ñ', 'Ü', '§',
      '¿', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
      'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'ä', 'ö', 'ñ', 'ü', 'à'
    ].freeze

    # Determines if the message can be encoded in GSM-7.
    def self.gsm7?(message)
      message.each_char.all? { |char| GSM_7BIT_CHARACTERS.include?(char) }
    end

    # Calculates the SMS segments and other details for the given message.
    #
    # Returns a hash with:
    #   :encoding          => :gsm7 or :unicode
    #   :segments          => number of segments
    #   :chars_per_segment => maximum characters per segment for the current message length
    #   :total_chars       => total characters in the message
    def self.calculate(message)
      if gsm7?(message)
        encoding = :gsm7
        if message.length <= 160
          segments = 1
          chars_per_segment = 160
        else
          segments = (message.length.to_f / 153).ceil
          chars_per_segment = 153
        end
      else
        encoding = :unicode
        if message.length <= 70
          segments = 1
          chars_per_segment = 70
        else
          segments = (message.length.to_f / 67).ceil
          chars_per_segment = 67
        end
      end

      {
        encoding: encoding,
        segments: segments,
        chars_per_segment: chars_per_segment,
        total_chars: message.length
      }
    end
  end
end
