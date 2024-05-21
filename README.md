# Cairo Language

- A Turing-complete language is fundamentally capable of performing any computation that can be described algorithmically
- Supports verifiable computation
- Blockchain developers that want to deploy contracts on Starknet will use the Cairo programming language to code their smart contracts.
- This allows the Starknet OS to generate execution traces for transactions to be proved by a prover, which is then verified on Ethereum L1 prior to updating the state root of Starknet.
- You can perform time consuming operations on a machine you don't trust, and check the result very quickly on a cheaper machine
- The point of Sierra is to ensure your CASM will always be provable, even when the computation fails. As opposed to in Cairo 0 where only successes were provable
- Instead of having *all* the participants of the network to verify all user interactions, *only one* node, called the __prover__, executes the programs and __generates proofs__ that the computations were done correctly unlike in Ethereum
- These proofs are then verified by an Ethereum smart contract, requiring significantly less computational power compared to executing the interactions themselves.
- This approach allows for __increased throughput__ and __reduced transaction costs__ while preserving Ethereum security

## Cairo 0 Flow

- Developer writes code in Cairo -> Comples to CASM -> Deploys CASM contract to Starknet
- On fail, an exception is raised and tx is not included in the block thus the sequencer doesn't profit so the sequencer did work for nothing. Only valid Cairo runs could be proved, which was a loss - This led to DDoS issues (bombard the sequencer with invalid txs) and anti-censorship (not knowing if transactions have been added rightfully or not)

## Features of Cairo

1. Program execution: prover vs verifier
2. Memory model: memory access always immutable. Cairo uses an immutable memory model

## Prover actual requirements

- Completteness: An honest prover should alwas be able to prove a run, even an invalid one
- Soundness: Prover must not be able to reject good runs
N/B: Solution, no failing code, i.e include branching instead of throwing exceptions, the reason for Sierra (*S*afe *I*nt*ER*mediate *R*epresent*A*tion)
- Starknet must not have any failing code in any contract. This was done by introducing the intermediate represenatation [Sierra has: __no fail semantics => safe by constructtion__ and __compiles down to CASM__ thus can't fail because it is constructed from non-failing semantic]

### Concrete Safety Issues (Illegal Operations)

1. Dereference illegal addresses
2. Undefined opcodes
3. Asserts (multiple writes to the same address, array multiple *appends* to the same position, wrongs mathematical asserts like division by 0, etc)
4. Long runs - halt or not?

### Design Goals

1. Safe
2. Efficient compilation
3. Simple
4. Low overhead - WYSIWYG (0-cost abstraction)
   N/B: Valid dereferences - Box, dereferencing only valid types, array double appends solved by linear type system (objects are used exactly once), same as dicts (dict_squash, value must be used)

## Starting Virtual Environment and Basic Cairo

- source /home/vik/.bashrc
- Cairo is a statically typed language, which means that it must know the types
of all variables at compile time
- A scalar type represents a single value. Cairo has three primary scalar types: felts, integers, and
booleans
- Felt252 is a *field element* in Cairo is an integer in the range 0 ≤ x < P, where is a very large prime number currently equal to 2^251 + 17 * 2^192 + 1 which is smaller than 2^252
- An integer is a number without a fractional component.

### Length Unsigned

1. 8-bit: u8
2. 16-bit: u16
3. 32-bit: u32
4. 64-bit: u64
5. 128-bit: u128
6. 256-bit: u256
7. 32-bit: usize
   N/B: Note that for now, the usize type is just an alias for u32.All integer types previously mentioned fit into a felt252 , except for u256 which needs 4 more
bits to be stored.

- Under the hood, u256 is basically a struct with 2 fields: u256 {low: u128,
high: u128}
- Cairo also provides support for signed integers, starting with the prefix i . These integers can
represent both positive and negative values, with sizes ranging from i8 to i128
- Each signed variant can store numbers from -(2^n-1) to (2^n-1) - 1. So an i8 can store numbers from -(2^7) to (2^7) - 1 which equals -128 to 127
- Note that number literals that can be multiple numeric types allow a type suffix, such as 57_u8 , to designate the type

### Integer literals in Cairo

*Numeric:* literals Example
*Decimal:* 98222
*Hex:* 0xff
*Octal:* 0o04321
*Binary:* 0b01

- Cairo doesn't have a native type for strings but provides two ways to handle them: *short strings*
using __simple quotes__ and *ByteArray* using __double quotes__.
- Cairo uses the felt252 for short strings. As the felt252 is on 251 bits, a short string is limited
to 31 characters (31 * 8 = 248 bits, which is the maximum multiple of 8 that fits in 251 bits)
- A tuple is a general way of grouping together a number of values with a variety of types into
one compound type
- Tuples have a fixed length: once declared, they cannot grow or shrink in
size
- A unit type is a type which has only one value () . It is represented by a tuple with no elements.
Its size is always zero, and it is guaranteed to not exist in the compiled code
- In Cairo, everything is an
expression, and an expression that returns nothing actually returns () implicitly.
- Because Cairo is an expression-based language, this is an important distinction to understand. Other languages don’t have the same distinctions
- Expressions do not include ending semicolons. If you add a semicolon to the end of an expression, you turn it into a statement, and it will then not return a
value
- Note: Cairo prevents us from running program with infinite loops by including a gas meter. The gas meter is a mechanism that limits the amount of computation that can be done in a program. By setting a value to the --available-gas flag, we can set the maximum amount of gas available to the program.
- Gas is a unit of measurement that expresses the computation cost of an instruction. When the gas meter runs out, the program will stop. In the previous case, we set the gas limit high enough for the the program to run for quite some time.
- In Cairo, memory is immutable, which means that it is not possible to modify the elements of an array once they've been added.
- You can only add elements to the end of an array and remove elements from the front of an array. These operations do not require memory mutation, as they involve updating pointers rather than directly modifying the memory cells.
- Box type: (Cairo's smart-pointer type) containing a snapshot to the element at the specified index if that element exists in the array
- The *get* method is useful when you expect to access indices that may not be within the array's bounds and want to handle such cases gracefully without panics
- Cairo uses a __linear type system__. In such a type system, any value (a basic type, a struct, an
enum) must be *used and must only be used once*. '__Used__' here means that the value is either __destroyed__ or __moved__.

### Destruction can happen in several ways

1. a variable goes out of scope.
2. a struct is destructured.
3. explicit destruction using destruct() .

__Moving__ a value simply means passing that value to another function.

### Cairo leverages its linear type system for two main purposes

1. Ensuring that all code is provable and thus verifiable.
2. Abstracting away the immutable memory of the Cairo VM.

- In Cairo, ownership applies to variables and not to values
- *Ownership* of a variable: the owner is the code that can read (and write if mutable) the variable.
-> Each variable in Cairo has an owner.
-> There can only be one owner at a time.
-> When the owner goes out of scope, the variable is destroyed
- A scope is the range within a program for which an item is valid

```cairo
      { // s is not valid here, it’s not yet declared
      let s = 'hello'; // s is valid from this point forward
      // do stuff with s
      } // this scope is now over, and s is no longer valid
```

- There are two important points in time here:

1. When s comes into scope, it is valid.
2. It remains valid until it goes out of scope
  
## Cairo References

1. ```consteval_int!``` is the macro for declaring a constant value requiring computation

## Cairo Datatypes

- Cairo is a statically typed language, which means that it must know the types
of all variables at compile time.

### Scalar Types

- A scalar type represents a single value. Cairo has three primary scalar types: Its default type is a field element
  
1. felts
2. integers
3. booleans.

- In Cairo, if you don't specify the type of a variable or argument, its type defaults to a field
element, represented by the keyword felt252
- integer types come with added security features that provide extra protection against potential vulnerabilities in the code, such as overflow and underflow checks
- An integer is a number without a fractional component
- So how do you know which type of integer to use? Try to estimate the max value your int ca have and choose the good size. The primary situation in which you’d use usize is when indexing some sort of collection.
- usize is an alias for u32, intended for indexing collections and may have future compatibility with MLIR (Multi-Level Intermediate Representation).

### String Types

- There are short strings (felt252: single quotes) and byte arrays (double quotes)

## FUNCTIONS

- Statements are instructions that perform some action and do not return a value.
- Expressions evaluate to a resultant value. Let’s look at some examples.
- An assignment operator does not evaluate to a value in Cairo as is in other languages. So the statement ```let y = 6``` cannot be written as ```let y = z = 6``` as is the case in other programming languages

## CONDITIONALS

- In Cairo, there is nothing like everything other than 0 is *true*, it must be explicitly a __boolean value__ for it to be correct.
- Cairo doesn't support instantiating a bool from a numeric literal anyway - you can only use true or
false to create a bool
- Cairo prevents us from running program with infinite loops by including a gas meter
- By setting a value to the --available-gas flag, we can set the maximum amount of gas available to the program
- Gas is a unit of measurement that expresses the computation cost of an instruction. When the gas meter runs out, the program will stop

## ARRAYS

- An array is a collection of elements of the same type. You can create and use array methods by
using the *ArrayTrait* trait from the core library.
- Arrays are, in fact, queues whose values can't be modified. This has to do with the fact that once a memory slot is written to, it cannot be overwritten, but only read from it
- You can only append items to the end of an array and remove items from the front.
- In Cairo, memory is immutable, which means that it is not possible to modify the elements of an array once they've been added.
- You can only add elements to the end of an array and remove elements from the front of an array
- These operations do not require memory mutation, as they involve updating pointers rather than directly modifying the memory cells.
- The __get function__ returns an *Option<Box<@T>>* , which means it returns an option to a Box type
(Cairo's smart-pointer type) containing a snapshot to the element at the specified index if that
element exists in the array
- The at function, on the other hand, directly returns a snapshot to the element at the specified
index using the unbox() operator to extract the value stored in a box.
- If the index is out of bounds, a panic error occurs. You should only use at when you want the program to panic if the provided index is out of the array's bounds, which can prevent unexpected behavior.
- In summary, use *at* when you want to panic on out-of-bounds access attempts, and use *get*
when you prefer to handle such cases gracefully without panicking.
- Span is a struct that represents a snapshot of an Array. All methods provided by Array can also be used with Span , except for the append() method.
- To create a Span of an Array , call the span() method: ```array.span();```

## DICTIONARIES

- Cairo provides in its core library a dictionary-like type. The ```Felt252Dict<T>``` data type
represents a collection of key-value pairs where each key is unique and associated with a
corresponding value
- The core functionality of a ```Felt252Dict<T>``` is implemented in the trait Felt252DictTrait
- which includes all basic operations. Among them we can find:

1. insert(felt252, T) -> () to write values to a dictionary instance and
2. get(felt252) -> T to read values from it

- Once you instantiate a ```Felt252Dict<T>``` , behind the scenes all keys have their associated values initialized as zero. This means that if for example, you tried to get the balance of an inexistent user you will get 0 instead of an error or an undefined value.
- This also means there is __no way to delete data from a dictionary__. Something to take into account when incorporating this structure into your code
- Cairo is at its core a non-deterministic Turing-complete programming language, very different from any other popular language in existence, which as a consequence means that dictionaries are implemented very differently as well!
- *One of the constraints* of Cairo's *non-deterministic design* is that its __memory system is immutable__, so in order to simulate mutability, the language implements ```Felt252Dict<T>``` as a list of entries
- Each of the entries represents a time when a dictionary was accessed for reading/updating/writing purposes. An entry has three fields:

1. A key field that identifies the key for this key-value pair of the dictionary.
2. A previous_value field that indicates which previous value was held at key .
3. A new_value field that indicates the new value that is held at key .

- If we try implementing ```Felt252Dict<T>``` using high-level structures we would internally defin it as ```Array<Entry<T>>``` where each ```Entry<T>``` has information about what key-value pair it
represents and the previous and new values it holds. The definition of ```Entry<T>``` would be

```Cairo
   struct Entry<T> {
   key: felt252,
   previous_value: T,
   new_value: T,
}
```

- For each time we interact with a ```Felt252Dict<T>``` , a new ```Entry<T>``` will be registered:
- *A get* would __register an entry__ where there is no change in state, and previous and new values are stored with the same value.
- *An insert* would __register a new ```Entry<T>```__ where the *new_value* would be the __element being inserted__, and the *previous_value* the __last element inserted__ before this. In case it is
the *first entry* for a certain key, then the previous value will __be zero__
- The use of this entry list shows how there isn't any rewriting, just the creation of new memory
cells per ```Felt252Dict<T>``` interaction. Example:

```text
balances.insert('Alex', 100_u64);
balances.insert('Maria', 50_u64);
balances.insert('Alex', 200_u64);
balances.get('Maria');

key      previous    new
-------------------------
Alex     0           100
Maria    0           50
Alex     100         200
Maria    50          50
```

- This approach to implementing ```Felt252Dict<T>``` means that for each read/write operation, there is a scan for the whole entry list in search of the last entry with the same key .
- Once the entry has been found, its new_value is extracted and used on the new entry to be added as
the previous_value
- This means that interacting with ```Felt252Dict<T>``` has a worst-case time complexity of O(n) where n is the number of entries in the list.
- One of the purposes of Cairo is, with the STARK proof system, to generate proofs of computational integrity.
- This means that you need to verify that program execution is correct and inside the boundaries of Cairo restrictions.
- One of those boundary checks consists of "dictionary squashing" and that requires information on both previous and new values for every entry
- *Squashing Dictionaries*: To verify that the proof generated by a Cairo program execution that used a ```Felt252Dict<T>``` is correct, we need to check that there wasn't any illegal tampering with the dictionary.
- This is done through a method called *squash_dict* that reviews each entry of the entry list and
checks that access to the dictionary remains coherent throughout the execution.
- *Dictionary Destruction* If you run the examples from Basic Use of Dictionaries, you'd notice that there was never a call to squash dictionary, but the program compiled successfully nonetheless
- What happene behind the scene was that squash was called automatically via the ```Felt252Dict<T>``` implementation of the ```Destruct<T>``` trait
- ```The Destruct<T>``` trait represents another way of removing instances out of scope apart from ```Drop<T>``` .
- The main difference between these two is that ```Drop<T>``` is treated as a no-op operation, meaning it does not generate new CASM while ```Destruct<T>``` does not have this restriction.
- The only type which actively uses the ```Destruct<T>``` trait is ```Felt252Dict<T>``` , for every other type ```Destruct<T>``` and ```Drop<T>``` are synonyms
- The *entry method* comes as part of ```Felt252DictTrait<T>``` with the purpose of creating a new
entry given a certain key. Once called, this method takes ownership of the dictionary and returns the entry to update

```Cairo
fn entry(self: Felt252Dict<T>, key: felt252) -> (Felt252DictEntry<T>, T) nopanic
```

- The first input parameter takes ownership of the dictionary while the second one is used to
create the appropriate entry. It returns a tuple containing a ```Felt252DictEntry<T>``` , which is the
type used by Cairo to represent dictionary entries, and a T representing the value held previously. The nopanic notation simply indicates that the function is guaranteed to never panic.
- The next thing to do is to update the entry with the new value. For this, we use the finalize
method which inserts the entry and returns ownership of the dictionary

```Cairo
fn finalize(self: Felt252DictEntry<T>, new_value: T) -> Felt252Dict<T>
```

- ```Felt252DictValue<T>``` defines the zero_default method which is the one that gets called when a value does not exist in the dictionary
- ```Nullable<T>``` is a smart pointer type that can either point to a value or be null in the absence
of value
- The difference with Option is that the wrapped value is stored inside a ```Box<T>``` data type. The ```Box<T>``` type, inspired by Rust, allows us to allocate a new memory segment for our type, and access this segment using a pointer that can only be manipulated in one place at a time

## Understanding Cairo's Ownership system

- Cairo is a language built around a linear type system that allows us to statically ensure that in
every Cairo program, a value is used exactly once
- This linear type system helps prevent runtime errors by ensuring that operations that could cause such errors, such as writing twice to a memory cell, are detected at compile time.
- This is achieved by implementing an ownership system and forbidding copying and dropping values by default.
- Cairo uses a linear type system. In such a type system, any value (a basic type, a struct, an enum) must be used and must only be used once.
- 'Used' here means that the value is either destroyed or moved.
- Destruction can happen in several ways:

1. a variable goes out of scope.
2. a struct is destructured.
3. explicit destruction using destruct()

- Moving a value simply means passing that value to another function.
- Cairo leverages its linear type system for two main purposes:

1. Ensuring that all code is provable and thus verifiable.
2. Abstracting away the immutable memory of the Cairo VM

i) Each variable in Cairo has an owner.
ii) There can only be one owner at a time.
iii) When the owner goes out of scope, the variable is destroyed.

- As said earlier, moving a value simply means passing that value to another function
- Arrays are an example of a complex type that is moved when passing it to another function.
- If a type implements the Copy trait, passing a value of that type to a function does not move the value. Instead, a new variable is created, referring to the same value
- While Arrays and Dictionaries can't be copied, custom types that don't contain either of them can be.
- You can implement the Copy trait on your type by adding the #[derive(Copy)] annotation to your type definition
- However, Cairo won't allow a type to be annotated with Copy if the type itself or any of its components doesn't implement the Copy trait.
- The other way linear types can be used is by being destroyed. Destruction must ensure that the 'resource' is now correctly released. In Cairo, one type that has such behaviour is Felt252Dict . For provability, dicts must be 'squashed' when they are destructed. This would be very easy to forget, so it is enforced by the type system and the compiler
- __No-op Destruction: the Drop Trait__
- The following code will not compile, because the struct A is not moved or destroyed before it goes out of scope

```Cairo
struct A {}
fn main() {
A {}; // error: Variable not dropped.
}
```

- However, types that implement the Drop trait are automatically destroyed when going out of scope
- This destruction does nothing, it is a no-op - simply a hint to the compiler that this type can safely be destroyed once it's no longer useful. We call this "dropping" a value.
- At the moment, the Drop implementation can be derived for all types, allowing them to be dropped when going out of scope, except for dictionaries ( Felt252Dict ) and types containing dictionaries. For example, the following code compiles

```Cairo
#[derive(Drop)]
struct A {}
fn main() {
A {}; // Now there is no error.
}
```

- __Destruction with a Side-effect__: the Destruct Trait__When a value is destroyed, the compiler first tries to call the drop method on that type.
- If it doesn't exist, then the compiler tries to call destruct instead. This method is provided by the
Destruct trait.
- As said earlier, dictionaries in Cairo are types that must be "squashed" when destructed, so that the sequence of access can be proven
- This is easy for developers to forget, so instead dictionaries implement the Destruct trait to ensure that all dictionaries are squashed when going out of scope

```Cairo
struct A {
dict: Felt252Dict<u128>
}
fn main() {
A { dict: Default::default() };
}
```

- Value not dropped compile error for the above code

```Cairo
#[derive(Destruct)]
struct A {
dict: Felt252Dict<u128>
}
fn main() {
A { dict: Default::default() }; // No error here
}
```

- The above code compiles. Now, when A goes out of scope, its dictionary will be automatically squashed , and the program will compile
- __Copy Array Data with clone__ If we do want to deeply copy the data of an Array , we can use a common method called clone

```Cairo
fn main() {
let arr1: Array<u128> = array![];
let arr2 = arr1.clone();
}
```

- Cairo does let us return multiple values using a tuple. But this is too much ceremony and a lot of work for a concept that should be common
- Cairo has two features for passing a value without destroying or moving it, called __references__ and __snapshots__.
- Cairo's ownership system prevents us from using a variable after we've moved it, protecting us from potentially writing twice to the same memory cell. However, it's not very convenient
- In Cairo, a snapshot is an immutable view of a value at a certain point in time. so modifying a value actually creates a new memory cell. The old memory cell still exists, and snapshots are variables that refer to that "old" value. In this sense, snapshots are a view "into the past"

```Cairo
fn main() {
   let mut arr1: Array<u128> = array![];
   let first_snapshot = @arr1; // Take a snapshot of `arr1` at this point in time
   arr1.append(1); // Mutate `arr1` by appending a value
   let first_length = calculate_length(
   first_snapshot
   ); // Calculate the length of the array when the snapshot was taken
   let second_length = calculate_length(@arr1); // Calculate the current length
   of the array
   println!("The length of the array when the snapshot was taken is {}",
   first_length);
   println!("The current length of the array is {}", second_length);
   }
fn calculate_length(arr: @Array<u128>) -> usize {
   arr.len()
}
```

- First, notice that all the tuple code in the variable declaration and the function return value is gone.
- Second, note that we pass @arr1 into calculate_length and, in its definition, we take ```@Array<u128>``` rather than ```Array<u128>``` .
- The `@arr1` syntax lets us create a snapshot of the value in arr1 . Because a snapshot is an immutable view of a value at a specific point in time, the usual rules of the linear type system are not enforced
- In particular, snapshot variables always implement the Drop trait, never the Destruct trait, even dictionary snapshots
- The scope in which the variable array_snapshot is valid is the same as any function parameter’s scope, but the underlying value of the snapshot is not dropped when array_snapshot stops being used
- When functions have snapshots as parameters instead of the actual values, we won’t need to return the values in order to give back ownership of the original value, because we never had it
- *Desnap Operator*: To convert a snapshot back into a regular variable, you can use the desnap operator * , which serves as the opposite of the @ operator
- Only Copy types can be desnapped. However, in the general case, because the value is not modified, the new variable created by the desnap operator reuses the old value, and so desnapping is a completely free operation, just like Copy
- We cannot modify values in a snapshot, though we can use __Mutable References__ instead of snapshots to assist in this.
- Mutable references are actually mutable values passed to a function that are implicitly returned at the end of the function, returning ownership to the calling context
- By
doing so, they allow you to mutate the value passed while keeping ownership of it by returning it automatically at the end of the execution. In Cairo, a parameter can be passed as mutable reference using the ref modifier

### Small Recap

- At any given time, a variable can only have one owner.
- You can pass a variable by-value, by-snapshot, or by-reference to a function.
- If you pass-by-value, ownership of the variable is transferred to the function.
- If you want to keep ownership of the variable and know that your function won’t mutate it, you can pass it as a snapshot with @ .
- If you want to keep ownership of the variable and know that your function will mutate it, you can pass it as a mutable reference with ref

## STRUCTS

- Used to group related data
- Structs and enums are the building blocks for creating new types in your program’s domain to take full advantage of Cairo's compile-time type checking.
- Note that the entire instance of a struct must be mutable; Cairo doesn’t allow us to mark only certain fields as mutable.
- As with any expression, we can construct a new instance of the struct as the last expression in the function body to implicitly return that new instance
- Unlike functions, methods are defined within the context of a type, either with their first parameter self which represents the instance of the type the method is being called on (als called instance methods), or by using this type for their parameters and/or return value (also called class methods in Object-Oriented programming).
- there is no direct link between a type and a trait. Only the type of the self parameter of a method defines the type from which this method can be called. That means, it is technically possible to define methods on multiple types in a same trait (mixing Rectangle and Circle methods, for example). But this is not a recommended practice as it can lead to confusion.
- It is possible to use a same name for a struct attribute and a method associated to this struct. For example, we can define a width method for the Rectangle type, and Cairo will know that my_rect.width refers to the width attribute while my_rect.width() refers to the width method. This is also not a recommended practice.
- To avoid defining useless traits, Cairo provides the #[generate_trait] attribute to add above a trait implementation, which tells to the compiler to generate the corresponding trait definition for you, and let's you focus on the implementation only
- Defining a trait and then implementing it to define methods on a specific type is verbose, and unnecessary: the trait itself will not be reused
- In Cairo, we can also define a method which doesn't act on a specific instance (so, without any self parameter) but which still manipulates the related type. This is what we call class methods in Object-Oriented programming
- As these methods are not called from an instance, we don't use them with the ```<instance_name> <method_name>``` syntax but with the ```<Trait_or_Impl_name>::<method_name>``` syntax.
- Each struct is allowed to have multiple trait and impl blocks. For example, the followin code is equivalent to the code shown in the Methods with several parameters section, which has each method in its own trait and impl blocks

## Enums and Pattern Matching

- Enums allow you to define a type by enumerating its possible variants
- Enums, short for "enumerations," are a way to define a custom data type that consists of a fixed set of named values, called variants
- Enums are useful for representing a collection of related values where each value is distinct and has a specific meaning.
- The naming convention is to use PascalCase for enum variants
- In Cairo, you can define traits and implement them for your custom enums. This allows you to define methods and behaviors associated with the enum. Here's an example of defining a trait and implementing it for the previous Message enum
- The Option enum is a standard Cairo enum that represents the concept of an optional value. It has two variants: Some: T and None . Some: T indicates that there's a value of type T , while None represents the absence of a value
- Enums can be useful in many situations, especially when using the match flow construct
- Cairo has an extremely powerful control flow construct called match that allows you to compare a value against a series of patterns and then execute code based on which pattern matches
- The power of match comes from the expressiveness of the patterns and the fact that the compiler confirms that all possible cases are handled.
- Another useful feature of match arms is that they can bind to the parts of the values that match the pattern. This is how we can extract values out of enum variants
- Matches in Cairo are exhaustive: we must exhaust every last possibility in order for the code to be valid
- __Catch-all with the _ Placeholder__
- __Multiple Patterns with the | Operator__
