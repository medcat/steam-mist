describe SteamMist::RequestUri do

  subject(:request_uri) do
    SteamMist::RequestUri.new(:interface => "ISomeInterface", :method => "SomeMethod", 
      :version => 1)
  end

  it "should raise an argument error" do
    expect { described_class.new(:something => :else) }.to raise_error(ArgumentError)
  end

  it "should return a uri" do
    request_uri.format_uri.should be_instance_of(URI::HTTP)
  end

  it "should format the right string" do
    request_uri.to_s.should eq "http://api.steampowered.com/ISomeInterface/SomeMethod/v0001?"
  end
end
