abstract class Object {}

mixin Hashable {}

class Array extends Object {
  Array(this.elements);
  List<Object> elements;
}

class Boolean extends Object with Hashable {
  // ignore: avoid_positional_boolean_parameters
  Boolean(this.value);
  bool value;
}
