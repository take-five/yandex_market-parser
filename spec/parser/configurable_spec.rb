require "spec_helper"

describe YandexMarket::Parser::Configurable do
  class Abstract
    extend YandexMarket::Parser::Configurable
  end

  class Parent < Abstract
    configure.shop do |s|
      s.xpath :@id => :id, :owner => :owner
      s.collect :id, :owner
    end
  end

  class Child < Parent
    configure.shop do |s|
      s.xpath :company => :company
      s.collect :company
      s.skip :owner
    end
  end

  describe Abstract do
    subject { Abstract }

    it { should respond_to(:configure) }
  end

  # testing inheritance here
  describe Parent do
    subject { Parent.configuration.shop }

    it { should be_collect(:id) }
    it { should be_collect(:owner) }
    it { should_not be_collect(:company) }
  end

  describe Child do
    subject { Child.configuration.shop }

    it { should be_collect(:id) }
    it { should_not be_collect(:owner) }
    it { should be_collect(:company) }
  end
end