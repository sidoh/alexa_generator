# alexa_generator

[![Gem Version](https://badge.fury.io/rb/alexa_generator.svg)](http://badge.fury.io/rb/alexa_generator)
[![Build Status](https://travis-ci.org/sidoh/alexa_generator.svg)](https://travis-ci.org/sidoh/alexa_generator)

Rubygem to generate the [interaction model](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interaction-model-reference) for Amazon's Alexa API.

## Installing

alexa_generator is available on [Rubygems](https://rubygems.org). You can install it with:

```
$ gem install alexa_generator
```

You can also add it to your Gemfile:

```
gem 'alexa_generator'
```

## What's this?

To register a skill with Amazon's Alexa API, one must create an *intent schema* and a list of *sample utterances*. I found this process to be really tedious, and wanted an easier and more maintainable way to define interaction models.

## Example usage

Here's an example of building the intent schema used in [Amazon's example](https://developer.amazon.com/public/solutions/alexa/alexa-skills-kit/docs/alexa-skills-kit-interaction-model-reference):

```ruby
model = AlexaGenerator::InteractionModel.build do |model|
  model.add_intent(:GetHoroscope) do |intent|
    intent.add_slot(:Sign, AlexaGenerator::Slot::SlotType::LITERAL) do |slot|
      slot.add_bindings(*%w{Aries Taurus Gemini Cancer Leo Virgo Libra Scorpio Sagittarius Capricorn Aquarius Pisces})
    end

    intent.add_slot(:Date, AlexaGenerator::Slot::SlotType::DATE) do |slot|
      slot.add_bindings('today', 'next Thursday', 'tomorrow')
    end

    intent.add_utterance_template('what is the horoscope for {Sign}')
    intent.add_utterance_template('what will the horoscope for {Sign} be {Date}')
  end
end
```

### Intent schema

One can then get the intent schema:

```ruby
model.intent_schema
# => {:intents=>[{:intent=>:GetHoroscope, :slots=>[{:name=>:Sign, :type=>:LITERAL}, {:name=>:Date, :type=>:DATE}]}]}
```

Amazon expects JSON as input, so you might want to convert:

```ruby
require 'json'
JSON.pretty_generate(model.intent_schema)
# => {
# =>   "intents": [
# =>     {
# =>       "intent": "GetHoroscope",
# =>       "slots": [
# =>         {
# =>           "name": "Sign",
# =>           "type": "LITERAL"
# =>         },
# =>         {
# =>           "name": "Date",
# =>           "type": "DATE"
# =>         }
# =>       ]
# =>     }
# =>   ]
# => }
```

### Sample utterances

`alexa_generator` generates all possible combinations of slot bindings and applies them to the provided sample utterance templates. In the above example:

```ruby
model.sample_utterances(:GetHoroscope)
```

will output the following (clipped for the sake of brevity):

```
GetHoroscope what is the horoscope for {Aquarius|Sign}
GetHoroscope what is the horoscope for {Aries|Sign}
GetHoroscope what is the horoscope for {Cancer|Sign}
GetHoroscope what is the horoscope for {Capricorn|Sign}
GetHoroscope what is the horoscope for {Gemini|Sign}
GetHoroscope what is the horoscope for {Leo|Sign}
GetHoroscope what is the horoscope for {Libra|Sign}
GetHoroscope what is the horoscope for {Pisces|Sign}
GetHoroscope what is the horoscope for {Sagittarius|Sign}
GetHoroscope what is the horoscope for {Scorpio|Sign}
GetHoroscope what is the horoscope for {Taurus|Sign}
GetHoroscope what is the horoscope for {Virgo|Sign}
GetHoroscope what will the horoscope for {Aquarius|Sign} be {next Thursday|Date}
GetHoroscope what will the horoscope for {Aquarius|Sign} be {today|Date}
GetHoroscope what will the horoscope for {Aquarius|Sign} be {tomorrow|Date}
[... clipped ...]
GetHoroscope what will the horoscope for {Taurus|Sign} be {next Thursday|Date}
GetHoroscope what will the horoscope for {Taurus|Sign} be {today|Date}
GetHoroscope what will the horoscope for {Taurus|Sign} be {tomorrow|Date}
GetHoroscope what will the horoscope for {Virgo|Sign} be {next Thursday|Date}
GetHoroscope what will the horoscope for {Virgo|Sign} be {today|Date}
GetHoroscope what will the horoscope for {Virgo|Sign} be {tomorrow|Date}
```
