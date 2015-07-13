require "spec_helper"

RSpec.describe NATS::Protocol do

  let(:sub) { "foo" }
  let(:msg) { "aloha" }
  let(:reply_to) { "_INBOX.123" }

  it "includes control line in every command" do
    encoded = NATS::Protocol.encode msg
    expect(encoded).to end_with(NATS::CR_LF)
  end

  it "encodes basic subscription requests" do
    command = [NATS::SUB, sub, 2 ]
    encoded = NATS::Protocol.encode command
    expect(encoded).to eq("SUB foo 2\r\n")
  end

  it "encodes subscription requests with queue groups" do
    command = [NATS::SUB, sub, "workers", 2 ]
    encoded = NATS::Protocol.encode command
    expect(encoded).to eq("SUB foo workers 2\r\n")
  end  

  it "encodes basic publish commands" do
    command = [NATS::PUB, sub, msg.bytesize, NATS::CR_LF, msg.to_s]
    encoded = NATS::Protocol.encode command
    expect(encoded).to eq("PUB foo 5\r\naloha\r\n")
  end

  it "encodes publish commands with reply info" do
    command = [NATS::PUB, sub, reply_to, msg.bytesize, NATS::CR_LF, msg.to_s]
    encoded = NATS::Protocol.encode command
    expect(encoded).to eq("PUB foo _INBOX.123 5\r\naloha\r\n")
  end

  it "encodes connection commands" do
    command = [ NATS::CONNECT, { :verbose => true, :pedantic => false }.to_json ]
    encoded = NATS::Protocol.encode command
    expected_command = 'CONNECT {"verbose":true,"pedantic":false}'
    expect(encoded).to eq("#{expected_command}\r\n")
  end

end