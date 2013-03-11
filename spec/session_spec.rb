describe SteamMist::Session do
  
  subject { SteamMist::Session.new(SteamMist::Connectors::LazyConnector) }
  
  it "should give an interface" do
    subject.get_interface(:some_interface) \
      .should be_instance_of(SteamMist::PseudoInterface)
  end
end
