require "rspec"
require "sms_credits"

RSpec.describe SmsCredits::Sanitizer do
  describe ".sanitize" do
    it 'sanitizes lookalike characters to GSM-7 equivalents' do
      message = %Q(Welcome to the “world” of SMS! Here’s a bullet point: •. This message costs €1. Cancellation policy applies – https://www.example.com.au/cancellation-policy/cp\nSee you soon! 2016©)
      sanitized_message = SmsCredits::Sanitizer.sanitize(message)

      expect(sanitized_message).to be_a Hash
      expect(sanitized_message[:sanitized_characters].sort).to eq(["“", "”", "’", "•", "€", "–", "©"].sort)
      expect(sanitized_message[:sanitized_message]).to eq("Welcome to the \"world\" of SMS! Here's a bullet point: *. This message costs EUR1. Cancellation policy applies - https://www.example.com.au/cancellation-policy/cp\nSee you soon! 2016(c)")
    end
  end
end