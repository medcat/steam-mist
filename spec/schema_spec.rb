describe SteamMist::Schema do

  subject { SteamMist::Schema.new(api_key, app_id, lang) }

  context "no language" do

    let(:api_key) { "" } # sorry, cant really figure out how to handle this
    let(:app_id) { 440 }
    let(:lang) { nil }

    it "retrieves data" do
      expect {
        subject.data
      }.to raise_error(OpenURI::HTTPError)
    end
  end
end