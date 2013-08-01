describe SteamMist::Connectors::LazyConnector do

  subject { described_class.new(request_uri) }
  let(:request_uri) { "https://api.twitter.com/1/statuses/oembed.json?id=133640144317198338" }

  it "can cache" do
    subject.enable_caching "tmp/example_cache.json"
    expect(subject).to be_cache
  end

  it "does cache" do
    subject.enable_caching "tmp/example_cache.json"
    subject.data
    expect { |p| subject.send(:with_cache, &p) }.to_not yield_control
  end

  it "loads from cache file" do
    subject.enable_caching "tmp/example_cache.json"
    expect { |p| subject.send(:with_cache, &p) }.to_not yield_control
  end

  after :all do
    File.unlink "tmp/example_cache.json"
  end
end