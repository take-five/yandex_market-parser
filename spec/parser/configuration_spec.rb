require "spec_helper"

describe YandexMarket::Parser::Configuration do
  Section = YandexMarket::Parser::Configuration::Section

  it { should respond_to(:catalog, :shop, :currencies, :categories, :offers) }

  describe Section do
    let(:section) { Section.new }

    describe "#xpath" do
      it "should stringify both keys and values" do
        section.xpath '@id' => :id, :companyId => :company_id
        section.map.should == {'@id' => 'id', 'companyId' => 'company_id'}
      end

      it "should merge xpath map" do
        section.xpath '@id' => :id
        section.xpath 'companyId' => :company_id
        section.map.should == {'@id' => 'id', 'companyId' => 'company_id'}
      end
    end

    describe "#collect" do
      specify "attributes should be set" do
        section.attributes.should be_a(Set)
      end

      it "should throw error when unknown attribute given" do
        expect{ section.collect :id }.to raise_error(ArgumentError)
      end

      it "should stringify values" do
        section.xpath '@id' => :id, :companyId => :company_id
        section.collect :id, :company_id

        section.attributes.to_a.should == %w(id company_id)
        section.clone.attributes.to_a.should == %w(id company_id)
      end
    end

    describe "#collect?" do
      it "should respond with true when collected attributes are given" do
        section.xpath '@id' => :id, :companyId => :company_id
        section.collect :id, :company_id

        section.collect?(:id).should be_true
        section.collect?(%w(id company_id)).should be_true
      end

      it "should respond with false when any of given attributes is not collected" do
        section.xpath '@id' => :id, :companyId => :company_id
        section.collect :id, :company_id

        section.collect?(:unknown).should be_false
        section.collect?(:id, :unknown).should be_false
      end
    end

    describe "#skip" do
      it "should not throw error when unknown attribute given" do
        expect{ section.skip :id }.not_to raise_error(ArgumentError)
      end

      it "should exclude attributes" do
        section.xpath '@id' => :id, :companyId => :company_id
        section.collect :id, :company_id
        section.skip :company_id
        section.attributes.to_a.should == %w(id)
      end
    end

    describe "#node_name" do
      it "should set node name" do
        section.node_name "shop"
        section.node.should eq "shop"
      end
    end

    describe "#convert" do
      it "should store converter" do
        section.xpath '@date' => :date
        section.transform :date, :with => DateTime

        section.converters.should have_key("date")
      end
    end

    describe "#extend" do
      let(:modul) do
        Module.new do
          def self.specific_module_method
          end

          def specific_instance_method
          end
        end
      end

      it "should extend generated subclasses with given module" do
        section.extend(modul)

        section.klass.should_not respond_to(:specific_module_method)
        section.klass.instance_methods.should include(:specific_instance_method)
      end

      it "should extend generated subclasses with given block" do
        section.extend do
          def self.specific_class_method
          end

          def specific_instance_method
          end
        end

        section.klass.should respond_to(:specific_class_method)
        section.klass.instance_methods.should include(:specific_instance_method)
      end
    end

    describe "#base_class" do
      it "should return YandexMarket::Model by default" do
        section.base_class.should == YandexMarket::Model
      end

      it "should set new base class" do
        klass = Class.new(YandexMarket::Model)
        section.base_class klass
        section.base_class.should == klass
      end

      it "should throw error when wrong class given" do
        klass = Class.new
        expect{ section.base_class klass }.to raise_error(TypeError)
      end

      it "should instantiate a successors of certain base class" do
        klass = Class.new(YandexMarket::Model)
        section.base_class klass

        section.klass.should < klass
      end
    end

    describe "#instantiate" do
      it "should return certain classes" do
        klass = Class.new(YandexMarket::Model)
        section.instantiate klass
        section.klass.should == klass
      end
    end
  end

  let(:cnf) { YandexMarket::Parser::Configuration.new }
  subject { cnf }

  its(:catalog) { should be_a Section }
  its(:shop) { should be_a Section }
  its(:currencies) { should be_a Section }
  its(:categories) { should be_a Section }
  its(:offers) { should be_a Section }

  it "should configire section" do
    subj = cnf.shop do |s|
      s.xpath :@id => :id
      s.collect :id
    end

    subj.should be_a Section
    subj.attributes.to_a.should eq %w(id)
  end

  it "should clone internals on duplication" do
    cnf.shop do |s|
      s.xpath :@id => :id
      s.collect :id
    end

    cnf_dup = cnf.dup
    cnf_dup.shop do |s|
      s.skip :id
    end

    cnf.shop.attributes.to_a.should == %w(id)
    cnf_dup.shop.attributes.should be_empty
  end
end