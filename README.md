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
