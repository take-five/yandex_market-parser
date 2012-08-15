require "spec_helper"

describe YandexMarket::Handler::CurrencyCollector do
  class CurrencyCollectorTestHandler < YandexMarket::Handler::Naive
    include YandexMarket::Handler::CurrencyCollector
  end

  class CurrencyCollectorTestParser < YandexMarket::Parser::Base
    configure.currencies do |c|
      c.collect :id
    end

    configure.offers do |c|
      c.collect :currency_id
    end

    configure.handler CurrencyCollectorTestHandler
  end

  let(:parser) { CurrencyCollectorTestParser.new }
  let(:currencies) { parser.handler.currencies }
  let(:offers) { parser.handler.objects.select { |o| o.node_name == 'offer' } }
  let(:rouble) { currencies["RUR"] }
  before { fixture("1.xml") { |f| parser.parse_stream(f) } }

  describe "currencies" do
    subject { currencies }

    it { should be_a Hash }
    it { should have(1).item }

    describe "rouble" do
      subject { rouble }

      it { should be_a YandexMarket::Model }
      its(:id) { should eq "RUR" }
    end
  end

  describe "offers" do
    subject { offers.first }

    it { should respond_to :currency }
    its(:currency) { should be rouble }
  end
end