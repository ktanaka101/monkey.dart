import 'package:monkey/monkey/evaluator/object.dart' as object;

class Environment {
  Environment({this.outer});
  factory Environment.newEnclose(Environment outer) =>
      Environment(outer: outer);

  Map<String, object.Object> scope = {};
  Environment? outer;

  object.Object? resolve(String key) {
    final obj = scope[key];
    if (obj is object.Object) {
      return obj;
    } else {
      return outer?.resolve(key);
    }
  }

  void insert(String key, object.Object value) {
    scope[key] = value;
  }
}
