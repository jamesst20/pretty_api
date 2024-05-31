# PrettyApi

Build API that feels like home using native built in Ruby on Rails and ActiveRecord `accepts_nested_attributes_for` but
without all the boilerplate code that makes your Javascript dirty.

## Comparison

Exemple with an organization that has 2 services. Let's say we would like to update one service and destroy the other.

#### Without PrettyAPI

```json
{
  "organization": {
    "id": 1,
    "services_attributes": [
      {
        "id": 1,
        "name": "Service to destroy",
        "_destroy": true
      },
      {
        "id": 2,
        "name": "Service to update"
      }
    ]
  }
}
```

### With PrettyAPI

You can omit `_attributes` from your attributes and you can omit everything that you would like to destroy as well.

```json
{
  "organization": {
    "id": 1,
    "services": [
      {
        "id": 2,
        "name": "Service to update"
      }
    ]
  }
}
```

More exemples

```javascript
{
  organization: {
    services: [] // Delete all services
  }
  
  organization: {
    // Fully omit "services" attribute to leave as is
  }
}
```

## How it works

Because Rails is a framework built on conventions over configurations, it is possible to use reflections on your
ActiveRecord models to automatically detect which attributes are expected to be "nested" by declaring properly your
nested attributes using `accepts_nested_attributes_for`.

## Why

In the past I have built many applications that were using frontend frameworks such as React, VueJS and Svelte built on
top of a Ruby on Rails API. Here are the things that always have irritated me

1. Transforming all my attributes to `_attributes` when the time comes to send my data to the API.
2. Keeping destroyed objects in my Arrays only to tell Rails to destroy them by sending `{ id: 1, _destroy: true }`

I have tried the approach of working directly with object instances but ActiveRecord behaves unexpectedly by saving
every associations as soon as you assign the parameters. Here is an exemple

```
params[:services]
=> { services: [] }

@organization.assign_attributes(params)
=> DELETE FROM services WHERE organization_id = 1;
```

You don't even have time to check for validation or do anything that ActiveRecord already destroyed every services in
the database that belongs to your organization.

## Installation

Add this line to your Gemfile:

    gem "pretty-api"

## Configuration

You can optionally create an initializer to configure these options
```
# Destroy associations that are omitted in your payload
PretttyApi.destroy_missing_associations = true
```

## Usage

```
class OrganizationsController < ApplicationController
  include PrettyApi::Helpers

  def create
    @organization = Organization.new
    @organization.assign_attributes(pretty_nested_attributes(@organization, organization_params))
    ...
  end
  
  def update
    @organization = Organization.find(...)
    @organization.assign_attributes(pretty_nested_attributes(@organization, organization_params))
    ...
  end

  private
  
  def organization_params
    params.require(:organization).permit(:name, services: [:id, :name])
  end
end
```

## This gem needs more testing

While this gem has some unit tests, it hasn't been battle tested yet.

## Beta feature

This is a new feature that I am testing to see if I can make validation errors
over API way easier to work with. By default ActiveRecord doesn't tell you which records in your
associations are invalid. This is making very hard to highlight the proper input field
in forms when you are working with nested forms.

```
include PrettyApi::Helpers

@organization.valid?
=> false

pretty_nested_errors(@organization)
=> {
  name: ["can't be blank"],
  organizations: {
    1 => { name: ["can't be blank"] }
    3 => { name: ["can't be blank"] }
  }
}
```

Note: There is a "somewhat" similar feature in ActiveRecord that is not well documented.
However, while the keys are indexed, they are in string format making it hard
to work with.

```
# Per association: 
has_many :my_associations, index_errors: true

# Globally:
config.active_record.index_nested_attribute_errors = true

# Before
product.error.messages
=> {:"variants.display_name"=>["can't be blank"], :"variants.price"=>["can't be blank"]}

# After
product.error.messages
{:"variants[0].display_name"=>["can't be blank"], :"variants[1].price"=>["can't be blank"]}
```


## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rspec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, 
which will create a git tag for the version, push git commits and the created tag, and push the `.gem` 
file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jamesst20/pretty_api.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
