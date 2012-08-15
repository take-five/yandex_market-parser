require "spec_helper"

describe YandexMarket::Parser do
  class TestParser < YandexMarket::Parser::Base
    configure.catalog do |c|
      c.collect :date
    end

    configure.offers do |c|
      c.collect :id, :available
    end

    configure.handler YandexMarket::Handler::Stats
  end

  subject(:parser) { TestParser.new }

  it "should parse" do
    fixture("1.xml") { |f| parser.parse_stream(f) }
    stats = parser.handler.stats

    stats['yml_catalog'].should == 1
    stats['shop'].should == 1
    stats['offer'].should == 2
  end

  it "should map xml nodes to attributes" do
    parser = TestParser.new(YandexMarket::Handler::Naive.new)

    fixture("1.xml") { |f| parser.parse_stream(f) }
    offers = parser.handler.objects.select { |o| o.node_name == 'offer' }

    offer = offers.first
    offer.id.should == "1"
    offer.available.should == true
  end
end