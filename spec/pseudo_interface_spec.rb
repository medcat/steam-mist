describe SteamMist::PseudoInterface do

  subject(:interface) do
    described_class.new(nil, :some_interface)
  end
  
  it "turns the interface name into the correct api name" do
    interface.api_name.should == "ISomeInterface"
  end

  it "gives a pseudo method" do
    interface.get_method(:some_method) \
      .should be_instance_of SteamMist::PseudoInterface::PseudoMethod
  end
end
