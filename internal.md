# Internal documentation

This documentation is not meant to be read by anybody. This document will be used for self documentations
to avoid forgetting important implementations motivations.

This gem can get a little confusing sometimes because `accepts_nested_attributes_for` can be used with any kind
of associations (has_many, belongs_to, has_one, has_many_though, ...) and it can also be used to self reference itself
or another association that reference itself. We must handle properly these use case properly to avoid infinite loop.

We are able to extract the dependency tree of an association with the internal method `nested_attributes_tree`. This
method can be bypassed by passing explicitly your own structure. As of today, the structure looks like this

```ruby
{
  CompanyCar => {
    organization: { allow_destroy: true, model: Organization, type: :belongs_to } 
  },
  Organization => { 
    company_car: { allow_destroy: true, model: CompanyCar, type: :has_one },
    services: { allow_destroy: true, model: Service, type: :has_many } 
  },
  Phone => {},
  Service => { 
    phones: { allow_destroy: true, model: Phone, type: :has_many } 
  }
}
```

### Notes on the pretty nested attributes implementation

We must never rely on parameters indexes to extract a record association. The order is not guaranteed and this could 
lead to odd behavior or potential accidental data loss. We must rely on the primary key of the record against the
given parameter. If not done properly, it would append in the parameters `{ id: ..., _destroy: true}` wrongly thinking
some associations dont exist. I believe ActiveRecord would raise a RecordNotFound exception to protect against this
scenario, however we have unit tests to protect against this scenario to avoid code regression in the future.
