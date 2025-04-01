require "rspec"
require "sms_credits"

RSpec.describe SmsCredits::Counter do
  describe ".gsm7?" do
    context "with GSM‑7 characters only" do
      it "recognizes a standard SMS greeting as GSM‑7" do
        message = "Hello, world! How are you doing today?"
        expect(SmsCredits::Counter.gsm7?(message)).to eq(true)
      end

      it "recognizes an empty message as GSM‑7" do
        message = ""
        expect(SmsCredits::Counter.gsm7?(message)).to eq(true)
      end

      it "handles realistic newlines and carriage returns" do
        message = "Dear John,\nYour appointment is confirmed.\rThank you for choosing our service."
        expect(SmsCredits::Counter.gsm7?(message)).to eq(true)
      end
    end

    context "with non GSM‑7 characters" do
      it "rejects a message with Japanese characters" do
        message = "こんにちは、元気ですか？"
        expect(SmsCredits::Counter.gsm7?(message)).to eq(false)
      end

      it "rejects a message with an emoji" do
        message = "Good morning! Have a great day 😊"
        expect(SmsCredits::Counter.gsm7?(message)).to eq(false)
      end

      it "rejects a message with an unsupported special symbol" do
        message = "Your total is €50. Please pay at the counter."
        expect(SmsCredits::Counter.gsm7?(message)).to eq(false)
      end
    end
  end

  describe ".calculate" do
    context "for GSM‑7 encoded messages" do
      it "processes a short SMS correctly" do
        message = "Hi there! I'll be arriving at 10:30 AM. See you soon."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "handles a realistic promotional SMS spanning multiple segments" do
        message = "Dear customer, thank you for choosing our service. We are excited to offer you exclusive discounts this week. Visit our website for more details and enjoy shopping with us."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to be > 1
      end

      it "confirms GSM‑7 encoding for an SMS with a typical address and punctuation" do
        message = "123 Main St., Apt 4B - New York, NY 10001. Call us for more information."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "handles SMS with realistic line breaks properly" do
        message = "Dear Customer,\nYour package has been shipped.\nTrack your order online."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "calculates segments for a multi-paragraph SMS message" do
        message = "Hello Team,\n\nPlease be reminded of the meeting tomorrow at 9 AM.\n\nBest regards,\nManagement"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "handles SMS with numbers and special characters" do
        message = "Call 123-456-7890 for info! Your code is 98765."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "calculates correct segments for a realistic social media update" do
        message = "Just had the best coffee at Central Perk! #coffee #friends #NewYork"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "processes an SMS containing a URL and alphanumeric text" do
        message = "Check out our new website at http://example.com for exclusive deals."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
      end

      it "processes a typical bank OTP message in GSM‑7" do
        message = "Your OTP for transaction is 452398. Do not share it with anyone."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
      end
    end

    context "for Unicode encoded messages" do
      it "processes a short Japanese message correctly" do
        message = "こんにちは、元気ですか？"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "handles a realistic long Japanese message spanning multiple segments" do
        message = "お客様へ、いつもご利用いただき誠にありがとうございます。今後とも変わらぬご愛顧を賜りますようお願い申し上げます。弊社では新しいサービスの提供を開始いたしました。"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        if result[:total_chars] > 70
          expect(result[:segments]).to be > 1
        else
          expect(result[:segments]).to eq(1)
        end
      end

      it "processes a short Arabic message correctly" do
        message = "مرحبا، كيف حالك؟"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "processes a short Cyrillic message correctly" do
        message = "Привет, как дела?"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "calculates segments for a mixed language message with Japanese and English" do
        message = "Hello, こんにちは. Welcome to our service."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "handles messages with diacritical marks in French" do
        message = "Bonjour, votre réservation a été confirmée pour le dîner ce soir à 19h30."
        result = described_class.calculate(message)
        # Depending on GSM‑7 support for accented characters, encoding could be GSM‑7 or Unicode.
        expect([:gsm7, :unicode]).to include(result[:encoding])
      end

      it "calculates segments for a long Chinese notification" do
        message = "尊敬的客户，您的订单已成功提交。请保持手机畅通，我们的客服将与您联系确认订单详情。谢谢您的支持！"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        if result[:total_chars] > 70
          expect(result[:segments]).to be > 1
        else
          expect(result[:segments]).to eq(1)
        end
      end

      it "handles a long Unicode message containing multiple paragraphs" do
        message = "亲爱的用户，\n感谢您注册我们的服务。\n请确认您的电子邮件地址以激活账号。\n如有疑问，请联系我们的客服团队。\n祝您生活愉快！"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        if result[:total_chars] > 70
          expect(result[:segments]).to be > 1
        else
          expect(result[:segments]).to eq(1)
        end
      end

      it "processes a message with multiple language scripts (Arabic, Cyrillic, and Latin)" do
        message = "مرحبا, привет, hello!"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "processes a message with accented characters and symbols typical in Spanish" do
        message = "¡Hola! ¿Cómo estás? Disfruta de una oferta exclusiva en tu tienda favorita."
        result = described_class.calculate(message)
        expect([:gsm7, :unicode]).to include(result[:encoding])
      end
    end

    context "for messages with emojis" do
      it "processes a message with a single emoji correctly" do
        message = "Have a nice day 😊!"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "processes a message with multiple emojis correctly" do
        message = "Party tonight! 🎉🎉🎉 Let's have fun and enjoy the night."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "processes a compound emoji in a realistic message" do
        message = "Sending love 👩‍❤️‍💋‍👩 from our team. Stay safe and take care!"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "processes a message with a mix of simple and compound emojis" do
        message = "Let's celebrate! 😊👩‍❤️‍💋‍👩🎉"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "processes a message with extended emojis (skin tone variations)" do
        message = "Thumbs up 👍🏽 for your efforts!"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "processes a message with a sequence of flag emojis" do
        message = "Travel updates: 🇺🇸🇬🇧🇫🇷🇩🇪 - check your itinerary."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "processes a realistic message with a mix of text, numeric information, and emojis" do
        message = "Order #78910 confirmed 🚀. Estimated delivery: 3-5 business days. Track your order online."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "processes a message with a long sequence of simple emojis" do
        message = "😊" * 20
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end
    end

    context "edge cases" do
      it "handles an empty message correctly as a GSM‑7 message" do
        message = ""
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "forces Unicode encoding when mixed languages are present" do
        message = "Hello, 世界. Your order has been shipped and will arrive soon."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
      end

      it "accurately reports the total character count in a realistic message" do
        message = "Your verification code is 834921. Please do not share it with anyone."
        result = described_class.calculate(message)
        expect(result[:total_chars]).to eq(message.length)
      end

      it "handles a message that exactly meets the GSM‑7 boundary of 160 characters" do
        message = "This is a confirmation message for your appointment. Please arrive 10 minutes early to complete the check-in process. Thank you."
        # Pad the message to exactly 160 characters
        message = message.ljust(160, ' ')
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:segments]).to eq(1)
      end

      it "handles a message that exactly meets the Unicode boundary of 70 characters" do
        message = "تم تأكيد موعدك مع الطبيب في العيادة."
        # Pad the message to exactly 70 characters
        message = message.ljust(70, ' ')
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to eq(1)
      end

      it "handles a message with only whitespace characters" do
        message = "     "
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
        expect(result[:total_chars]).to eq(message.length)
      end

      it "handles a message with only punctuation" do
        message = "!!!???...---"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:gsm7)
      end
    end

    context "boundary conditions for mixed text and emojis" do
      it "transitions to multiple Unicode segments when realistic text plus an emoji push it over the limit" do
        base_message = "Reminder: your meeting is at 2 PM. Please be on time 😊."
        result_base = described_class.calculate(base_message)
        expect(result_base[:encoding]).to eq(:unicode)
        expect(result_base[:segments]).to eq(1)

        over_message = base_message + " Kindly confirm your attendance."
        result_over = described_class.calculate(over_message)
        expect(result_over[:encoding]).to eq(:unicode)
        expect(result_over[:segments]).to eq(2)
      end

      it "handles realistic mixed messages with multiple emojis spanning multiple segments" do
        mixed_message = "Dear customer, your order #12345 has been shipped 🚚. It is expected to arrive by tomorrow. Thank you for shopping with us! 😊"
        result = described_class.calculate(mixed_message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:total_chars]).to eq(mixed_message.length + 2)
        if result[:total_chars] > 70
          expect(result[:segments]).to be > 1
        else
          expect(result[:segments]).to eq(1)
        end
      end

      it "transitions from two segments to three segments in a realistic social update with multiple emojis" do
        message = "Breaking News: Our concert tonight is sold out! 🎤🎸 Enjoy the after-party at 11 PM. Stay tuned for more updates and thank you for your support! 😊"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        expect(result[:segments]).to be >= 2

        extended_message = message + " Don't forget to check our website for the latest announcements."
        result_extended = described_class.calculate(extended_message)
        expect(result_extended[:segments]).to be > result[:segments]
      end

      it "handles realistic message with punctuation and emoji near Unicode segment boundary" do
        message = "Alert: Your flight has been delayed by 30 minutes. Please check the terminal information 😊."
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        if result[:total_chars] > 70
          expect(result[:segments]).to be > 1
        else
          expect(result[:segments]).to eq(1)
        end
      end

      it "handles a message with mixed language text and multiple punctuation marks pushing Unicode segment boundary" do
        message = "Notice: 您的包裹已到达. Please collect it from the reception, merci! 😊"
        result = described_class.calculate(message)
        expect(result[:encoding]).to eq(:unicode)
        if result[:total_chars] > 70
          expect(result[:segments]).to be > 1
        else
          expect(result[:segments]).to eq(1)
        end
      end
    end
  end
end