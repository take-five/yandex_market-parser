# YandexMarket::Parser [![Build Status](https://secure.travis-ci.org/take-five/yandex_market-parser.png?branch=master)](http://travis-ci.org/take-five/yandex_market-parser)

<tt>YandexMarket::Parser</tt> is a parsers generator. Generated parsers are SAX-based XML parsers for [YandexML](http://partner.market.yandex.ru/legal/tt/) files.

## Installation

Add this line to your application's Gemfile:

    gem 'yandex_market-parser', :git => "git://github.com/take-five/yandex_market-parser.git"

And then execute:

    $ bundle

## Usage

The way to customize processing of Yandex.Market XML files is to define Parser and Controller.

Parser is responsible for reading file, recognizing its structure and map XML-nodes to Ruby objects.
Controller is responsible for the rest part of work - it processes objects received from Parser.

To create a parser you should create a new class - successor of YandexMarket::Parser::Base, and configure YML-specific sections. In each section you should define of which attributes you are interested. Some attributes are already mapped to standard XML-nodes. Anyway, you can map some specific attributes by yourself.
```ruby
class MyCoolParser < YandexMarket::Parser::Base
  configure.catalog do |c|
    c.collect :date
  end

  configure.offers do |c|
    c.xpath 'oferta/@id' => :oferta_id # custom mapping
    c.collect :id, :price, :oferta_id
    # you can specify a base class for generated classes (it should be successor of YandexMarket::Model)
    c.base_class MyCoolOffer
    # alternatively you can specify a concrete class for section
    c.instantiate MyCoolOffer # no additional classes shall be generated
  end
end
```

To create a controller you should create a new class - successor of YandexMarket::Controller::Base. You should implement main methods: catalog, shop, currency, category, offer
```ruby
class MyCoolController < YandexMarket::Controller::Base
  def catalog(o)
  end

  def shop(o)
  end

  def currency(o)
  end

  def category(o)
  end

  def offer(o)
  end
end
```

There is already few predefined controllers, they are designed mainly for testing purposes:
1. YandexMarket::Controller::Naive - it just stores all objects to array, and it is accessible by method +objects+
2. YandexMarket::Controller::Stats - counts nodes by node type, statistics is accessible by method +stats+

And now you can parse YML-files:
```ruby
controller = MyCoolController.new
parser  = MyCoolParser.new(controller)
parser.parse_stream(File.open('/tmp/yandex.xml'))
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
