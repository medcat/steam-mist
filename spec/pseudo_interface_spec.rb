describe SteamMist::PseudoInterface do

  subject(:interface) do
    described_class.new(nil, :some_interface)
  end
  
  it "should turn the interface name into the correct api name" do
    interface.api_name.should == "ISomeInterface"
  end

  it "should give a pseudo method" do
    interface.get_method(:some_method) \
      .should be_instance_of described_class::PseudoMethod
  end

  it "should always give the same pseudo method" do
    interface.get_method(:some_method) \
      .should be interface.get_method(:some_method)
  end
end
