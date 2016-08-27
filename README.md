# GiftWrap

A simple Ruby presenter library, for those who enjoy a strong separation of concerns.


## What does that mean?

A presenter is just a decorator that is specifically concerned with the presentation layer. GiftWrap provides a simple way to "wrap" a domain entity (e.g. model) for the purpose of decorating it with said presentational logic.

That sort of "view logic" almost never belongs deep in the core code of your domain entities. Yet somehow throwing together classes to house it elsewhere can feel like a chore comprised mostly of boilerplate.

GiftWrap removes this feeling while also being lightweight enough that reading the entire source takes only a few minutes. The core module weighs in at **about 70 lines of code and no dependencies**. Even the optional helpers for those who use ActiveRecord weigh in at only an additional 30 lines of code, give or take.

Even better, any model logic which is not relevant to presentation or view code is not accidentally accessible on a class implementing `GiftWrap::Presenter` (e.g. persistence code doesn't leak through to templates).

## Other Options

Competition benefits the consumer, and in this case that's you! There is another great gem that does this named [Draper](https://github.com/drapergem/draper), which used to it call itself a "decorator" library, but now focuses on being a tool for "view models". Don't let this indecision in terminology distract from the incredible amount of features and flexibility the project has developed over the last several years.

Another project, [Rectify](https://github.com/andypike/rectify), has a presenter library included in it the same goal as GiftWrap. Rectify's presenters take a more Rails-specific approach, and joins this author in criticizing Rails' use of the term "view" for what are just templates.

In both libraries' cases (barring abuse of certain Draper features), separating a domain entity's multi-faceted presentational needs from any internal or persistence logic is achieved just as as well as by GiftWrap. These libraries are equally useful contenders to consider if you like the extras they provide: a large feature set for Draper, additional abstractions in the case of Rectify.


## Overview of Use

0. `gem install 'gift_wrap'`
1. `include GiftWrap::Presenter` in a PORO, a Plain Old Ruby Object.
2. Call `wrapped_as` with some entity/model name.
3. Write your own presentational methods in a safe, isolated place.

Optionally, you can delegate methods directly with `unwrap_for` if desired, or use `wrap_association` to keep your presenters referencing each other, instead of letting them meddle in associated core domain models.


## What You Get

- A place to isolate all presentational logic related to a particular domain concept or model.
- An `attributes` method for capturing a user-defined set methods as a Hash.
- Easy delegation to the underlying model with `unwrap_for`. Use sparingly and with great dicipline.
- Short-hand to declare unwrapped methods as attributes, via `attribute: true` in the call to `unwrap_for`.
- The ability to include any methods you define in the usual manner (i.e. `def make_some_noise`) as an attribute.
- _Optional_ JSON serialization via `ActiveModel::Serializers::JSON`, derived `attributes`.
- A way to declare an unwrapped method as an "associations" which should be wrapped in their own presenter class.
- Array-valued associations are built as an array of the association's presenter class.

You might even have one model with two distinct presenters that display the model's attributes in a different manner which are particular to their use in your system's presentation layer.



## Simple Use

Consider a model class representing a map. A `Map` is of a certain type (physical, political, traffic, etc.), has a defined center point, associated units, a legend and possibly some notes. Some maps show roads, while others do not.

Here is such a class:

```ruby
class Map
  attr_reader :type, :center, :units, :legend
  attr_accessor :notes

  def initialize(type, center, units, legend = :asshole_mapmaker_forgot_legend)
    @type   = type
    @center = center
    @units  = units
    @notes  = ""
    @legend = legend
  end

  def shows_roads?
    maps_with_roads.include?(type)
  end

private

  def maps_with_roads
    ['road', 'traffic', 'political']
  end
end
```

Now consider a minimal presenter which delegates the `type` and `units` methods, and adds a few presentation-specific methods:

```ruby
class SimpleMapPresenter
  include GiftWrap::Presenter

  unwrap_for :type
  unwrap_for :units, attribute: true

  attribute :metric

  def metric
    metric_map_units.include?(units)
  end

  def contains_region?(region_name)
    false # Implementation not important
  end

  private

  def metric_map_units
    ['m', 'km']
  end
end
```

The methods `type` and `units` are delegated via `unwrap_for`, with `units` being declared as an attribute.

The additional presentational methods are `contains_region?` and `metric`, with `metric` being declared as an attribute.

Thus a call to `SimpleMapPresenter#attributes` would return a Hash with the keys `:units` and `:metric`, and because they are not explicitly delegated or otherwise referenced, the methods `center`, `legend` and `shows_roads?` on a `Map` object are not accessible on the presenter object.


## Explicit Reference of Wrapped Object

In case you would like to internally access the object which your presenter wraps by a domain-appropriate name, the method `wrapped_as` allows for this.

If in the above `Map` class we used this, we could refer to the map by name within instance methods of the presenter. For example, exposing a `has_notes?` method without allowing access to the `notes` method on the map itself:

```ruby
class SimpleMapPresenter
  include GiftWrap::Presenter

  wrapped_as :map

  # Previous implementation goes here

  def has_notes?
    map.notes && map.notes.length > 0
  end
end
```

Or better yet, when providing a default message for missing values, you can keep clunky-looking conditional code such as
```erb
<% if map.notes.length > 0 %>
  <%= map.notes %>
<% else %>
  (No notes provided)
<% end  %>
```
out of your templates entirely! Behold:

```ruby
class SimpleMapPresenter
  include GiftWrap::Presenter

  wrapped_as :map

  # Previous implementation goes here

  def has_notes?
    map.notes && map.notes.length > 0
  end

  def notes
    has_notes? ? map.notes : "(No notes provided)"
  end
end
```

Then your view template simply becomes

```erb
<%= map_presenter.notes %>
```


## Associated Objects with their own Presenters

Looking at our simple Map class, we've ignored its `legend` attribute entirely. This is likely expressed as an object with behavior of its own:

```ruby
class Legend
  def initialize(colored_regions, colored_lines)
    @colored_regions  = colored_regions
    @colored_lines    = colored_lines
  end

  def region_meaning(color)
    @colored_regions[color]
  end

  def line_meaning(color)
    @colored_lines[color]
  end
end
```

The `Legend` class can be given two hashes which define some of its colors. So for instance, a traffic map might have a legend which is passed colors for land and water regions, and then any colored lines represent traffic congestion:

```ruby
traffic_map_legend = Legend.new(
  { beige:  "land",
    blue:   "water"
  },
  { green:  "no congestion",
    yellow: "light congestion",
    red:    "heavy congestion",
    black:  "impassable"
  })
```

And accordingly would have its own presenter when it is used in any presentation or view layer of a project:

```ruby
class LegendPresenter
  include GiftWrap::Presenter

  unwrap_for :line_meaning

  attribute :red_lines

  def red_lines
    line_meaning(:red)
  end

  def yellow_lines
    line_meaning(:yellow)
  end

  def green_lines
    line_meaning(:green)
  end
```

And an example of its use:

```ruby
traffic_legend_presenter = LegendPresenter.new(traffic_map_legend)
traffic_legend_presenter.red_lines
# => "heavy congestion"
traffic_legend_presenter.yellow_lines
# => "light congestion"
traffic_legend_presenter.green_lines
# => "no congestion"
traffic_legend_presenter.black_lines
# => NoMethodError: undefined method `black_lines'
```

A presenter which wraps a `Map` object and which wishes to expose its `Legend` object would do well to instead expose an instance of `LegendPresenter`. It is preferable to keep adjacent code working at the same level of abstraction where possible.

Slavishly re-implementing a method with `def legend` only to return an instance of `LegendPresenter` seems a bit boilerplate, so GiftWrap has a convenience for this:

```ruby
class LegendaryMapPresenter
  include GiftWrap::Presenter

  unwrap_for :type, :units

  wrap_association :legend, with: LegendPresenter

  def metric?
    metric_map_units.include?(units)
  end

  private

  def metric_map_units
    ['m', 'km']
  end
end
```

Unlike the `SimpleMapPresenter`, this version has a `legend` method which performs this wrapping for us by calling `wrap_association` and passing the class `LegendPresenter` in the `:with` keyword.

## Customizing Associated Presenters

If the name `legend` was for some reason not desirable, there is no need for the method name exposed on the presenter to be the same of that on the wrapped object. Specifying the association's method name is just another keyword argument in the call to `wrap_association`. If the above class instead had
```ruby
wrap_association :legend, with: LegendPresenter, as: :roflcopter
```
Then the associated `Legend`, wrapped in a `LegendPresenter`, would be accessible via `map_presenter.roflcopter` instead of `map_presenter.legend`.

Association Presenters can also be **specified on a per-instance basis**, for flexible modification of presentational logic. So if we were malicious map makers and gave a traffic map legend for which every line color meant "no congestion", we could write such a class:

```ruby
class MisleadingLegendPresenter
  include GiftWrap::Presenter

  unwrap_for :line_meaning

  def red_lines
    "no congestion"
  end

  def yellow_lines
    "no congestion"
  end

  def green_lines
    "no congestion"
  end
end
```

And build our presenter for the traffic map as before, but override the presenter for the `legend` association. This is accomplished by an `:associations` keyword that simply maps the association name to the presenter which should be used. So given a traffic map stored in a variable named `map_with_legend` which references our previous `traffic_map_legend` as its legend:

```ruby
map_presenter = LegendaryMapPresenter.new(map_with_legend, associations: {
  legend: MisleadingLegendPresenter
})
traffic_legend_presenter = map_presenter.legend
```

The instance-specific presenter will take effect and `traffic_legend_presenter` will act quite differently than before:

```ruby
traffic_legend_presenter.red_lines
# => "no congestion"
traffic_legend_presenter.yellow_lines
# => "no congestion"
traffic_legend_presenter.green_lines
# => "no congestion"
```


## JSON Serialization

Although [the `activemodel` gem](https://rubygems.org/gems/activemodel) is not a depedency of GiftWrap, if it is included in a project, then by default `GiftWrap::Presenter` will also include `ActiveModel::Serializers::JSON` for use of its `to_json` and `as_json` methods.

This can be explicitly controlled via the GiftWrap's one and only configuration option. In some code that is executed at load-time, do the following:

```ruby
GiftWrap.configure do |config|
  config.use_serializers = false # or true if desired
end
```

**A known issue/limitation:** The serializer module also comes with a `from_json` method, but (depending on `activemodel` version) this relies on being able to write directly to an attributes hash via an `attributes=` method, or on having writer methods for every attribute. This is somewhat contrary to the way in which attributes can come from any presentation logic computed by a method which is declared with the `attribute` class macro. While this discrepancy is undesirable, the only solution might be to remove the `from_json` method after inclusion.


## ActiveRecord Convenience Module

GiftWrap does not depend on, or require ActiveRecord. But for those who are using GiftWrap as presentational wrappers for ActiveRecord models, an convenience module is provided: `GiftWrap::ActiveRecordPresenter`. It includes the standard `GiftWrap::Presenter` but provides an additional convenience method: `unwrap_columns_for` which will set up an attribute for every column detected on a given ActiveRecord subclass at load time.

Assuming a `User` class inheriting from `ActiveRecord::Base` with a `first_name`, `last_name`, `email` and `password` column in the backing database's table, then:
```ruby
class UserPresenter
  unwrap_columns_for User
end
```
Will call `unwrap_for` on all four of those columns, and also declare them as attributes. Similar to individual calls to `unwrap_for`, passing an `:attribute` keyword parameter allows explicitly setting this to `true`, or to not set any columns as attributes by passing `attribute: false`.

However, automatically setting all columns to true will cause methods such as `to_json` and `attributes` to include some data that might be undesirable to expose in a view layer. Like a `password` column for instance. Consequently, the `:attribute` keyword argument can also accept a hash with the key of `:only` or `:except`, which map to the column names which should be included or excluded from being attributes, respectively.

For example, to avoid making our above User's password an attribute:
```ruby
class UserPresenter
  unwrap_columns_for User, attribute: { except: [:password] }
end
```
