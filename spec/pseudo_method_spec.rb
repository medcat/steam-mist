describe SteamMist::PseudoInterface::PseudoMethod do

  subject(:pseudo_method) do
    session = SteamMist::Session.new(SteamMist::Connectors::LazyConnector)
    session.default_arguments[:something] = "value"
    interface = SteamMist::PseudoInterface.new(session, :some_interface) 
    described_class.new(interface, :some_method, 4)
  end

  it "should turn the method name into an api name" do
    pseudo_method.api_name.should == "SomeMethod"
  end

  it "should return a copy when adding arguments" do
    pseudo_method.with_arguments(:hello => "world").should_not be pseudo_method
  end

  it "should return a copy when changing versions" do
    pseudo_method.with_version(3).should_not be pseudo_method
  end

  it "should return a request uri" do
    pseudo_method.request_uri.should be_instance_of SteamMist::RequestUri
  end

  it "should give a connector instance" do
    pseudo_method.get.should be_instance_of SteamMist::Connectors::LazyConnector
  end

  it "should use default arguments" do
    pseudo_method.request_uri.arguments.should include(:something => "value")
  end
end
