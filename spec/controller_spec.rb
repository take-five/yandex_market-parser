require "spec_helper"

describe YandexMarket::Controller do
  class TestController < YandexMarket::Controller::Base
    attr_reader :stats

    def initialize
      @stats = Hash.new do |h, k|
        h[k] = 0
      end
    end

    def catalog o
      @stats[:catalog] += 1
    end

    def shop o
      @stats[:shop] += 1
    end
  end

  subject { TestController.new }
  let(:catalog) { YandexMarket::Parser::Base.configuration.catalog.klass.new }
  let(:shop) { YandexMarket::Parser::Base.configuration.shop.klass.new }
  let(:currency) { YandexMarket::Parser::Base.configuration.currencies.klass.new }

  before { subject << catalog }
  before { subject << shop }

  its(:stats) { should == {:catalog => 1, :shop => 1} }
  it { expect{ subject << currency }.to raise_error(NotImplementedError) }
end