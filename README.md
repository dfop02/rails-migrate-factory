# Rails Migrate Factory
Completely rebuild your migrations to agilize setup and simplify schema

## Install

`gem install migrate_factory_rails`

or add to your `Gemfile`

```ruby
group :development do
  gem 'migrate_factory_rails'
end
```

## How use

**Be careful, rebuild do not cover all situations yet then may miss some migration**
You can use two commands currently:

- `rake rebuild:migrations` -> Will rebuild all your migrations and save on `tmp/rebuild`, then you can validate if it worths without lose any data.
- `rake rebuild:cleanup`    -> Will cleanup all data on `tmp/rebuild`.

## Goals

My goal here was the challenge to rebuild every migrations from Rails, matching as close as possible the final `schema.rb` meanwhile reducing strongly the amount of migrations. Specially on old projects, there will be a lot ot migrations, sometimes for a single column or index which extends the setup for a few seconds. If is worth or not to use, feel free to discuss.

## Author

* [Diogo](https://github.com/dfop02)
