require "spec_helper"

describe YandexMarket::Controller::CategoryCollector do
  class CategoryCollectorTestController < YandexMarket::Controller::Naive
    include YandexMarket::Controller::CategoryCollector
  end

  class CategoryCollectorTestParser < YandexMarket::Parser::Base
    configure.categories do |c|
      c.collect :id, :parent_id, :title
    end

    configure.offers do |c|
      c.collect :category_id
    end

    configure.controller CategoryCollectorTestController
  end

  let(:parser) { CategoryCollectorTestParser.new }
  let(:categories) { parser.controller.categories }
  let(:offers) { parser.controller.objects.select { |o| o.node_name == 'offer' } }
  let(:action_category) { categories[4] }
  before { fixture("1.xml") { |f| parser.parse_stream(f) } }

  describe "categories" do
    subject { categories }

    it { should be_a Hash }
    it { should have(6).items }

    describe "action" do
      subject { action_category }

      it { should be_a YandexMarket::Model::Category }
      its(:id) { should eq 4 }
      its('parent.id') { should eq 1 }
    end
  end

  describe "offers" do
    subject { offers.first }

    it { should respond_to :category }
    its(:category) { should be action_category }
  end
end