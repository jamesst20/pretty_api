## [Unreleased]

## [0.5.0] - 2024-06-04

- Add new method aliases: `pretty_attrs` and `pretty_errors`

## [0.4.1] - 2024-06-04

- Fix `undefined method `each' for nil` when PrettyAPI is used on record that doesn't have associations

## [0.4.0] - 2024-06-04

- Add support for www-form-urlencoded / multipart format: Fix "No implicit conversion of String into Integer"

## [0.3.1] - 2024-06-01

- Fix possible "Unitialized Constant" error when inferring association classes that are namespaced

## [0.3.0] - 2024-06-01

- Support for ActionController::Parameters from Rails
- Support for self-referencing associations
- Support for circular accepts_nested_attributes_for
- Fix inaccurate destroy for nested attributes
- More specs

## [0.1.0] - 2024-05-30

- Initial release
