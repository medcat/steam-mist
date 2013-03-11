require 'stringio'

describe SteamMist::Rcon::Packet do
  it "should format itself correctly" do
    subject.id = 5
    subject.type = 2
    subject.body << "hello world"

    subject.format.should eq "\x15\0\0\0\x05\0\0\0\x02\0\0\0hello world\0\0"
  end

  it "should properly deserialize data from raw" do
    packet = described_class.from_raw "\x15\0\0\0\x05\0\0\0\x02\0\0\0hello world\0\0"
    packet.id.should be 5
    packet.type.should be 2
    packet.body.should eq "hello world"
  end

  it "should properly deserialize data from a stream" do
    s = StringIO.new "\x15\0\0\0\x05\0\0\0\x02\0\0\0hello world\0\0"
    packet = described_class.from_stream s
    packet.id.should be 5
    packet.type.should be 2
    packet.body.should eq "hello world"
  end
end
