abstract class Object {}

mixin Hashable {}

class Array extends Object with Hashable {
  Array(this.elements);
  List<Object> elements;
}
