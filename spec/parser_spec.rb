require "spec_helper"

describe YandexMarket::Parser do
  class TestParser < YandexMarket::Parser::Base
    configure.catalog do |c|
      c.collect :date
    end

    configure.offers do |c|
      c.collect :id, :available
    end

    configure.controller YandexMarket::Controller::Stats
  end

  subject(:parser) { TestParser.new }

  it "should parse" do
    fixture("1.xml") { |f| parser.parse_stream(f) }
    stats = parser.controller.stats

    stats['yml_catalog'].should == 1
    stats['shop'].should == 1
    stats['offer'].should == 3
  end

  it "should map xml nodes to attributes" do
    parser = TestParser.new(YandexMarket::Controller::Naive.new)

    fixture("1.xml") { |f| parser.parse_stream(f) }
    offers = parser.controller.objects.select { |o| o.node_name == 'offer' }

    offer = offers.first
    offer.id.should == "1"
    offer.available.should == true
  end

  it "should map xml nodes to attributes" do
    parser = TestParser.new(YandexMarket::Controller::Naive.new)

    fixture("1.xml") { |f| parser.parse_stream(f) }
    offers = parser.controller.objects.select { |o| o.node_name == 'offer' }

    offer = offers.first
    offer.id.should == "1"
    offer.available.should == true
  end

  it "should throw error when malformed XML is parsed" do
    expect { fixture("malformed.xml") { |f| parser.parse_stream(f) } }.to raise_error(SaxStream::ParsingError)
  end
end