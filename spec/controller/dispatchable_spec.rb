require "spec_helper"

describe YandexMarket::Controller::Dispatchable do
  class DispatchableTest
    extend YandexMarket::Controller::Dispatchable

    dispatch do |d|
      d.route 'foo' => :foo,
              'bar' => :bar
    end

    before_foo :before_foo
    after_foo  :after_foo
    before_bar :before_bar
    after_bar  :after_bar

    def foo() end
    def bar() end
    def before_foo() end
    def after_foo() end
    def before_bar() end
    def after_bar() end
  end

  class SymbolPropertyDispatchableTest < DispatchableTest
    dispatch do |d|
      d.property :to_s
    end
  end

  class StringPropertyDispatchableTest < DispatchableTest
    dispatch do |d|
      d.property "to_s"
    end
  end

  class ProcPropertyDispatchableTest < DispatchableTest
    dispatch do |d|
      d.property proc { |o| o.to_s }
    end
  end

  shared_examples "dispatchable" do |klass|
    subject { klass.new }

    its(:class) { should respond_to :before_foo }
    its(:class) { should respond_to :after_foo }

    its(:class) { should respond_to :before_bar}
    its(:class) { should respond_to :after_bar }

    it { should respond_to :dispatch }

    it "should call +foo+ when foo is received" do
      subject.should_receive(:foo).once
      subject.should_receive(:before_foo).once
      subject.should_receive(:after_foo).once
      subject.dispatch("foo")
    end

    it "should call +bar+ when bar is received" do
      subject.should_receive(:bar).once
      subject.should_receive(:before_bar).once
      subject.should_receive(:after_bar).once
      subject.dispatch("bar")
    end

    it "should raise error when unkonwn is received" do
      expect{ subject.dispatch("unknown") }.to raise_error(YandexMarket::Controller::DispatchError)
    end
  end

  it_behaves_like "dispatchable", SymbolPropertyDispatchableTest
  it_behaves_like "dispatchable", StringPropertyDispatchableTest
  it_behaves_like "dispatchable", ProcPropertyDispatchableTest

  context "given a dispatcher with invalid property" do
    let(:klass) { Class.new{ extend YandexMarket::Controller::Dispatchable } }

    it "should raise error" do
      expect { klass.dispatcher { |d| d.property 2 } }.to raise_error(TypeError)
    end
  end

  context "given a dispatcher with invalid routes" do
    let(:klass) { Class.new{ extend YandexMarket::Controller::Dispatchable } }

    it "should raise error" do
      expect { klass.dispatcher { |d| d.route 2 } }.to raise_error(TypeError)
    end
  end
end