describe SteamMist::Rcon::PacketFactory do
  it "should generate sequential packets" do
    packet1 = subject.create_packet
    packet2 = subject.create_packet

    (packet1.id + 1).should be packet2.id
  end
end
