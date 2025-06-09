require "rspec"
require "sms_credits"

RSpec.describe SmsCredits do
  context "for GSM‑7 encoded messages" do

    it "calculates 1 segment when message length is <= 160" do
      message = "a" * 160
      result = described_class.count(message)
      expect(result).to eq(1)
    end

    it "calculates concatenated segments for messages longer than 160 characters" do
      message = "a" * 161
      result = described_class.count(message)
      expect(result).to eq(2)
    end

    it "correctly calculates segments when message length is exactly 160" do
      message = "a" * 160
      result = described_class.count(message)
      expect(result).to eq(1)
    end

    it 'counts emojis correctly' do
      expect(::SmsCredits::Counter.calculate("😊😊")[:total_chars]).to eq(4)
      expect(::SmsCredits::Counter.calculate("Ok thanks! 😊😊")[:total_chars]).to eq(15)
      expect(described_class.count("Whoa 😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊😊")).to eq(2)
    end

    it "transitions from one to multiple segments at 161 characters" do
      message1 = "a" * 160
      message2 = "a" * 161
      expect(described_class.count(message1)).to eq(1)
      expect(described_class.count(message2)).to eq(2)
    end

    it "calculates proper segments for longer messages" do
      # For GSM‑7, after the first segment (160), subsequent segments hold 153 characters.
      # For example, a message with 313 characters:
      # segments = ceil(313 / 153) = ceil(2.045) = 3 segments.
      message = "a" * 313
      result = described_class.count(message)
      expect(result).to eq(3)
    end
  end

  context "for Unicode encoded messages" do

    it "calculates 1 segment when a Unicode message length is <= 70" do
      message = "あ" * 70
      result = described_class.count(message)
      expect(result).to eq(1)
    end

    it "calculates concatenated segments for Unicode messages longer than 70 characters" do
      message = "あ" * 71
      result = described_class.count(message)
      expect(result).to eq(2)
    end

    it "calculates proper segments for longer Unicode messages" do
      # For Unicode, after the first segment (70), subsequent segments hold 67 characters.
      # For a message of 150 characters: segments = ceil(150 / 67) = ceil(2.2388) = 3 segments.
      message = "あ" * 150
      result = described_class.count(message)
      expect(result).to eq(3)
    end

    it "transitions from one to multiple segments at 71 characters" do
      message1 = "あ" * 70
      message2 = "あ" * 71
      expect(described_class.count(message1)).to eq(1)
      expect(described_class.count(message2)).to eq(2)
    end
  end

  context "edge cases" do
    it "handles an empty message correctly as a GSM‑7 message" do
      result = described_class.count("")
      expect(result).to eq(1)
    end
  end

  context "boundary conditions" do
    it "calculates exactly 1 segment for a GSM‑7 message at 160 characters" do
      message = "a" * 160
      result = described_class.count(message)
      expect(result).to eq(1)
    end

    it "calculates a segmentation jump for GSM‑7 when moving from 160 to 161 characters" do
      message1 = "a" * 160
      message2 = "a" * 161
      result1 = described_class.count(message1)
      result2 = described_class.count(message2)
      expect(result1).to eq(1)
      expect(result2).to eq(2)
    end

    it "calculates exactly 1 segment for a Unicode message at 70 characters" do
      message = "あ" * 70
      result = described_class.count(message)
      expect(result).to eq(1)
    end

    it "calculates a segmentation jump for Unicode messages when moving from 70 to 71 characters" do
      message1 = "あ" * 70
      message2 = "あ" * 71
      result1 = described_class.count(message1)
      result2 = described_class.count(message2)
      expect(result1).to eq(1)
      expect(result2).to eq(2)
    end
  end

  context "sanitization" do
    it 'sanitizes lookalike characters to GSM-7 equivalents' do
      message = %Q(Welcome to the “world” of SMS! Here’s a bullet point: •. This message costs €1. Cancellation policy applies – https://www.example.com.au/cancellation-policy/cp\nSee you soon! 2016©)
      sanitized_message = described_class.sanitize(message)

      expect(sanitized_message).to be_a String
      expect(sanitized_message).to include('"world"')
      expect(sanitized_message).to include('*')
      expect(sanitized_message).to include('EUR1')
      expect(sanitized_message).to include('-')
      expect(sanitized_message).to include('(c)')
    end

    it 'shows information about illegal characters that cant be sanitized' do
      message = "Hello, this is a test message with illegal characters: 😊, ©, ™, and €."
      info = described_class.info(message)

      expect(info[:illegal_characters]).to include('😊')
      expect(info[:sanitized_characters].sort).to eq(['©', '™', '€'].sort)
      expect(info[:sanitized_message]).to include('Hello, this is a test message with illegal characters: 😊, (c), (tm), and EUR.')
      expect(info[:encoding]).to eq(:unicode)
      expect(info[:segments]).to eq(2)
    end
  end
end