# monkey.rs

## Summury

We can learn how to make an interpreter in this book.  
====> ☆☆☆ **["Writing An Interpreter in Go"](https://interpreterbook.com/)** ☆☆☆  
That interpreter is called Monkey in the book.  
The Monkey is written in Go in the book.  
But in this repository it is written in Dart.

## Supports

- [x] Lexer
- [x] Parser
- [x] Evaluator
- [ ] Compiler
- [ ] VM
- [x] REPL
- [x] Test case
- [ ] Evaluator and VM benchmarks

## Example

### REPL

```sh
$ dart run
>> let a = 5
>> a + 10
15
>> let new_closure = fn(a) { fn() { a; }; };
>> let closure = new_closure(99);
>> closure();
99
```

### Fibonacchi

```monkey
let fibonacci = fn(x) {
  if (x == 0) {
    return 0;
  } else {
    if (x == 1) {
      return 1;
    } else {
      fibonacci(x - 1) + fibonacci(x - 2);
    } 
  }
};
fibonacci(15); #=> 610
```

```
$ dart run
>> let fibonacci = fn(x) { if (x == 0) { return 0; } else { if (x == 1) { return 1; } else { fibonacci(x - 1) + fibonacci(x - 2); } } };
>> fibonacci(15)
610
```

## Contributors

- [ktanaka101](https://github.com/ktanaka101) - creator, maintainer

## License

MIT
