# Internal documentation

This documentation is not meant to be read by anybody. This document will be used for self documentations
to avoid forgetting important implementations motivations.

This gem can get a little confusing sometimes because `accepts_nested_attributes_for` can be used with any kind
of associations (has_many, belongs_to, has_one, has_many_though, ...) and it can also be used to self reference itself
or another association that reference itself. We must handle properly these use case to avoid infinite loop.

We are able to extract the dependency tree of an association with the internal method `nested_attributes_tree`. This
method is implemented in two formats: one that returns an array structure, one that returns an hash structure. The library
itself doesn't make any use of two formats, however we do want to support to type of structure for better user
experience and compatibility. This is mostly useful for unit testings but this allow users to use the structure they
want when they pass manually the association tree to the public helpers method.

### Notes on the pretty nested attributes implementation

We must never rely on parameters indexes to extract a record association. The order is not guaranteed and this could 
lead to odd behavior or potential accidental data loss. We must rely on the primary key of the record against the
given parameter. If not done properly, it would append in the parameters `{ id: ..., _destroy: true}` wrongly thinking
some associations dont exist. I believe ActiveRecord would raise a RecordNotFound exception to protect against this
scenario, however we have unit tests to protect against this scenario to avoid code regression in the future.

Internally it infers automatically the dependency tree of a record by calling `nested_attributes_tree` or by receiving
an hash or an array by the user explicitly. This is subject to the spoken hash or array format spoken earlier.