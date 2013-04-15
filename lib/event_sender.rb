# Makes `send_event` public by wrapping
# real sender (`main` in dashing.rb) which defines private `send_event`.
class EventSender
  def initialize(real_sender)
    @real_sender = real_sender
  end

  def send_event(*args, &block)
    @real_sender.send(:send_event, *args, &block)
  end
end

# Use this constant in your jobs.
SENDER = EventSender.new(self)
