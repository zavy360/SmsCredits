## SMS Credit Counter
Complete re-implementation of [TwilioEd's MessageSegmentCalculator](https://github.com/TwilioDevEd/message-segment-calculator) for Ruby, using ChatGPT o3-mini-high and Github Copilot.

SmsCredits is a Ruby gem that calculates the number of SMS segments required to send a given text message. It determines whether a message can be encoded using GSM‑7 (with proper handling of extended characters) or needs Unicode encoding, and then computes the effective length, the number of segments, and the remaining characters available in the current segment.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sms_credits'
```

### Usage

```ruby
require 'sms_credits'

message = "Your SMS message here"
result = SmsCreditCounter::Counter.calculate(message)
puts "Encoding: #{result[:encoding]}"
puts "Segments: #{result[:segments]}"
puts "Characters per segment: #{result[:chars_per_segment]}"
puts "Total characters: #{result[:total_chars]}"
```

Or, if you just need the number of segments:

```ruby
require 'sms_credits'


SmsCredits.count("Hello") == 1
SmsCredits.count("Hello 😊") == 1

```