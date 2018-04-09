## 以太坊虚拟机

### 简介
常见的虚拟机一般分为两类：

* 虚拟机(Virtualbox, VMware)

* Java虚拟机

虚拟机技术（像Virtualbox, VMware)是在硬件和宿主操作系统上为每个客户操作系统虚拟一套独立于实际硬件的系统, 并处理系统调用，程序调度，资源管理等。

但是像JAVA虚拟机，跟以太坊虚拟机做类似的事情。JAVA虚拟机提供一个运行的环境来隔离操作系统和硬件，使相同的代码能在不同的操作系统上运行。在JAVA虚拟机上运行的高级语言如：Java、Scala，它们根据虚拟机规范，编译成JVM的指令字节码。JVM针对不同的操作系统，根据JVM指令来调用操作系统的底层命令。以太坊虚拟机也需要将Solidity源代码编译，再在EVM上运行。

#### 以太坊虚拟机语法

以太坊虚拟机指令可以归类为以下几个方面：数字操作，逻辑和比较操作，流程控制，系统调用，栈操作，以及内存控制。除了典型的字节码操作外，它还管理账户信息（列如：地址和余额），当前的gas price, 以及区块信息。

1. 堆栈和内存操作指令

	* POP     //Pop item off the stack
	* PUSH    //Push item on the stack
	* MLOAD   //Load item into memory
	* MSTORE  //Store item in memory
	* JUMP    //Alter the location of program counter (PC)
	* PC      //Program counter
	* MSIZE   //Active memory size
	* GAS     //Amount of available gas for transaction
	* DUP     //Stack item duplication
	* SWAP    //Stack item exchange operation

2. 系统指令

	* CREATE  //Create a new account
	* CALL    //Instruction for message passing between accounts
	* RETURN  //Execution halt
	* REVERT  //Execution halt, reverting state changes
	* SELFDESTRUCT //Execution halt, and flag account for deletion

3. 数字操作指令

	* ADD      //Add
	* MUL      //Multiplication
	* SUB      //Subtraction
	* DIV      //Integer division
	* SDIV     //Signed integer division
	* MOD      //Modulo (Remainder) operation
	* SMOD     //Signed modulo operation
	* ADDMOD   //Modulo addition
	* MULMOD   //Modulo multiplication
	* EXP      //Exponent operation
	* STOP     //Halt operation

3. 环境指令

	* ADDRESS        //Address of current execution account
	* BALANCE        //Account balance
	* CALLVALUE      //Transaction value for execution environment
	* ORIGIN         //Origin address of execution environment
	* CALLER         //Address of execution caller
	* CODESIZE       //Execution environment code size
	* GASPRICE       //Gas price state
	* EXTCODESIZE    //An account's code size
	* RETURNDATACOPY //Copy of data output from previous memory call

#### 以太坊虚拟机状态

[[evm_state_descriptions]]
==== State

As with any computing system, the concept of state is an important one. Just like a CPU keeping track of a process in execution, the EVM must keep track of the status of various components in order to support a transaction. The status or _state_ of these components ultimately drives the level of change in the overarching blockchain. This aspect leads to the description of Ethereum as a _transaction-based state machine_ containing the following components:

World State:: A mapping between 160-bit address identifiers and account state, maintained in an immutable _Merkle Patricia Tree_ data structure.

Account State:: Contains the following four components:

* _nonce_: A value representing the number of transactions sent from this respective account.

* _balance_: The number of _Wei_ owned by the account address.

* _storageRoot_: A 256-bit hash of the Merkle Patricia Tree's root node.

* _codeHash_: An immutable hash value of the EVM code for the respective account.

Storage State:: Account specific state information maintained at runtime on the EVM.

Block Information:: The state values needed for a transaction include the following:

* _blockhash_: The hash of the most recently completed blocks.

* _coinbase_: The address of the recipient.

* _timestamp_: The current block's timestamp.

* _number_: The current block's number.

* _difficulty_: The current block's difficulty.

* _gaslimit_: The current block's gas-limit.

Runtime Environment Information:: Information used to facilitate transactions.

* _gasprice_: Current gas price, which is specified by the transaction initiator.

* _codesize_: Size of the transaction codebase.

* _caller_: Address of the account executing the current transaction.

* _origin_: Address of the current transactions original sender.



State transitions are calculated with the following functions:

Ethereum State Transition Function:: Used to calculate a _valid state transition_.

Block Finalization State Transition Function:: Used to determine the state of a finalized block as part of the mining process, including block reward.

Block Level State Transition Function:: The resulting state of the Block Finalization State Transition Function when applied to a transaction state.

[[compiling_solidity_to_evm]]
==== Compiling Solidity to EVM bytecode

[[solc_help]]
Compiling a Solidity source file to EVM bytecode can be accomplished via the command line. For a list of additional compile options, simply run the following command:

----
$ solc --help
----

[[solc_opcodes_option]]

Generating the raw opcode stream of a Solidity source file is easily achieved with the _--opcodes_ command line option. This opcode stream leaves out some information (the _--asm_ option produces the full information), but is sufficient for this first introduction. For example, compiling an example Solidity file _Example.sol_ and populating the opcode output into a directory named _BytecodeDir_ is accomplished with the following command:

----
$ solc -o BytecodeOutputDir --opcodes Example.sol
----

or

[[solc_asm_option]]
----
$ solc -o BytecodeOutputDir --asm Example.sol
----

[[solc_bin_option]]
The following command will produce the bytecode binary for our example program:

----
$ solc -o BytecodeOutputDir --bin Example.sol
----

The output opcode files generated will depend on the specific contracts contained within the Solidity source file. Our simple Solidity file _Example.sol_ <<simple_solidity_example>> has only one contract named "example".

[[simple_solidity_example]]
----
pragma solidity ^0.4.19;

contract example {

  address contractOwner;

  function example() {
    contractOwner = msg.sender;
  }
}
----


If you look in the _BytecodeDir_ directory, you will see the opcode file _example.opcode_ (see <<simple_solidity_example>>) which contains the EVM machine language opcode instructions of the "example" contract. Opening up the _example.opcode_ file in a text editor will show the following:

[[opcode_output]]
----
PUSH1 0x60 PUSH1 0x40 MSTORE CALLVALUE ISZERO PUSH1 0xE JUMPI PUSH1 0x0 DUP1 REVERT JUMPDEST CALLER PUSH1 0x0 DUP1 PUSH2 0x100 EXP DUP2 SLOAD DUP2 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF MUL NOT AND SWAP1 DUP4 PUSH20 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF AND MUL OR SWAP1 SSTORE POP PUSH1 0x35 DUP1 PUSH1 0x5B PUSH1 0x0 CODECOPY PUSH1 0x0 RETURN STOP PUSH1 0x60 PUSH1 0x40 MSTORE PUSH1 0x0 DUP1 REVERT STOP LOG1 PUSH6 0x627A7A723058 KECCAK256 JUMP 0xb9 SWAP14 0xcb 0x1e 0xdd RETURNDATACOPY 0xec 0xe0 0x1f 0x27 0xc9 PUSH5 0x9C5ABCC14A NUMBER 0x5e INVALID EXTCODESIZE 0xdb 0xcf EXTCODESIZE 0x27 EXTCODESIZE 0xe2 0xb8 SWAP10 0xed 0x
----

Compiling the example with the _--asm_ option produces a file labed _example.evm_ in our _BytecodeDir_ directory. This contains the detailed EVM machine language instructions:

[[asm_output]]
----
/* "Example.sol":26:132  contract example {... */
  mstore(0x40, 0x60)
    /* "Example.sol":74:130  function example() {... */
  jumpi(tag_1, iszero(callvalue))
  0x0
  dup1
  revert
tag_1:
    /* "Example.sol":115:125  msg.sender */
  caller
    /* "Example.sol":99:112  contractOwner */
  0x0
  dup1
    /* "Example.sol":99:125  contractOwner = msg.sender */
  0x100
  exp
  dup2
  sload
  dup2
  0xffffffffffffffffffffffffffffffffffffffff
  mul
  not
  and
  swap1
  dup4
  0xffffffffffffffffffffffffffffffffffffffff
  and
  mul
  or
  swap1
  sstore
  pop
    /* "Example.sol":26:132  contract example {... */
  dataSize(sub_0)
  dup1
  dataOffset(sub_0)
  0x0
  codecopy
  0x0
  return
stop

sub_0: assembly {
        /* "Example.sol":26:132  contract example {... */
      mstore(0x40, 0x60)
      0x0
      dup1
      revert

    auxdata: 0xa165627a7a7230582056b99dcb1edd3eece01f27c9649c5abcc14a435efe3bdbcf3b273be2b899eda90029
}
----

The _--bin_ option produces the following:

[[bin_output]]
----
60606040523415600e57600080fd5b336000806101000a81548173
ffffffffffffffffffffffffffffffffffffffff
021916908373
ffffffffffffffffffffffffffffffffffffffff
160217905550603580605b6000396000f3006060604052600080fd00a165627a7a7230582056b99dcb1e
----

Let's examine the first two instructions (reference <<common_stack_opcodes>>):

[[opcode_analysis_1]]
----
PUSH1 0x60 PUSH1 0x40
----

Here we have the _mnemonic_ "PUSH1" followed with a raw byte of value "0x60". This corresponds to the EVM instruction of interpreting the single byte following the opcode as a literal value and pushing it onto the stack. It is possible to push values of size up to 32 bytes onto the stack. For example, the following bytecode pushes a 4 byte value onto the stack:

[[opcode_analysis_2]]
----
PUSH4 0x7f1baa12
----

The second push opcode stores "0x40" onto the stack (on top of "0x60" already present there).

Moving on to the next two instructions:

[[opcode_analysis_3]]
----
MSTORE CALLVALUE
----

MSTORE is a stack/memory operation (see <<common_stack_opcodes>>) that saves a value to memory, while CALLVALUE is an environmental opcode (see <<common_environment_opcodes>>) that returns the deposited value of the executing message call.

[[evm_bytecode_execution]]
==== Execution of EVM bytecode

[[gas_accounting_execution]]
==== Gas, Accounting

For every transaction, there is an associated _gas-limit_ and _gas-price_ which make up the fees of an EVM execution. These fees are used to facilitate the necessary resources of a transaction, such as computation and memory. Gas is also used for the creation of accounts and smart-contracts.

[[turing_completeness_and_gas]]
==== Turing Completeness and Gas

In simple terms, a system or programming language is _Turing complete_ if it can solve any problem you feed into it. This is discussed in the Ethereum Yellow Paper:

[quote, Gavin Wood, ETHEREUM: A SECURE DECENTRALISED GENERALISED TRANSACTION LEDGER]
____________________________________________________________________
It is a _quasi_-Turing complete machine; the quasi qualification comes from the fact that the computation is intrinsically bounded through a parameter, gas, which limits the total amount of computation done.
____________________________________________________________________

While the EVM can theoretically solve any problem it receives, gas is what might prevent it from doing so. This could occur in a few ways:

1) Blocks that get mined in Ethereum have a gas limit associated with them; that is, the total gas used by all the transactions inside the block can not exceed a certain limit.
2) Since gas and gas price go hand-in-hand, even if the gas limit restrictions were lifted, highly complex transactions may be economically infeasible.

For the majority of use cases, however, the EVM can solve any problem provided to it.

==== Bytecode vs. Runtime Bytecode

When compiling a contract, you can either get the _contract bytecode_ or the _runtime bytecode_.

The contract bytecode contains the bytecode of what will actually end up sitting on the blockchain _plus_ the bytecode needed to place that bytecode on the blockchain and run the contract's constructor.

The runtime bytecode, on the other hand, is _only the bytecode that ends up sitting on the blockchain_. This does not include the bytecode needed to initialize the contract and place it on the blockchain.

Let's take the simple `Faucet.sol` contract we created earlier as an example.

----
// Version of Solidity compiler this program was written for
pragma solidity ^0.4.19;

// Our first contract is a faucet!
contract Faucet {

  // Give out ether to anyone who asks
  function withdraw(uint withdraw_amount) public {

      // Limit withdrawal amount
      require(withdraw_amount <= 100000000000000000);

      // Send the amount to the address that requested it
      msg.sender.transfer(withdraw_amount);
    }

  // Accept any incoming amount
  function () public payable {}

}
----

To get the contract bytecode, we would run `solc --bin Faucet.sol`. If we instead wanted just the runtime bytecode, we would run `solc --bin-runtime Faucet.sol`.

If you compare the output of these commands, you will see that the runtime bytecode is a subset of the contract bytecode. In other words, the runtime bytecode is entirely contained within the contract bytecode.

==== Disassembling the Bytecode

After getting the runtime bytecode of Faucet.sol, we can enter it into Binary Ninja using the Ethersplay plugin to see what the EVM instructions look like.

[[Faucet_disassembled]]
.Disassembling the Faucet runtime bytecode
image::images/Faucet_disassembled.png["Faucet.sol runtime bytecode disassembled"]


When you direct a transaction to a smart contract, the first piece of code your transaction interacts with is that contract’s **dispatcher**. The dispatcher takes the transaction data and sends it to the appropriate function.

After the familiar MSTORE instruction, we see:

----
PUSH1 0x4
CALLDATASIZE
LT
PUSH1 0x3f
JUMPI
----

"PUSH1 0x4" places 0x4 onto the top of the stack, which is otherwise empty. "CALLDATASIZE" gets the size, in bytes, of the calldata of the transaction sent to the contract and pushes it onto the stack.

This next instruction is LT, short for “less than”. The LT instruction checks whether the top item on the stack is less than the next item on the stack. In our case, it checks to see if the result of CALLDATASIZE is less than 4 bytes.

Why does the EVM check to see that the calldata of the transaction is at least 4 bytes? Because of how function identifiers work. Each function is identified by the first four bytes of its keccak256 hash. By placing the function's name and what arguments it takes into a keccak256 hash function, you can extract its function identifier. In our contract, we have:

```
keccak256("withdraw(uint)") = 0x2e1a7d4d...
```
 evm.asciidoc                                                                                                                                                                                    << buffers
[[evm_chapter]]
== Ethereum Virtual Machine

[[evm_description]]
=== What is it?

[[evm_comparison]]
==== Compare to

* Virtual Machine (Virtualbox, QEMU, cloud computing)

* Java VM

Virtual Machine technologies such as Virtualbox and QEMU/KVM differ from the EVM in that their purpose is to provide hypervisor functionality, or a software abstraction that handles system calls, task scheduling, and resource management between a guest OS and the underlying host OS and hardware.

Certain aspects of the Java VM (JVM) specification however, do contain similarities to the EVM. From a high-level overview, the JVM is designed to provide a runtime environment that is irrespective of the underlying host OS or hardware, enabling compatibility across a wide variety of systems. High level program languages such as Java or Scala that run on the JVM are compiled into the respective instruction set bytecode. This is comparable to compiling a Solidity source file to run on the EVM.

[[evm_bytecode_overview]]
==== EVM Machine Language (Bytecode Operations)

The EVM Machine Language is divided into specific instruction set groups, such as arithmetic operations, logical and comparison operations, control flow, system calls, stack operations, and memory operations. In addition to the typical bytecode operations, the EVM must also manage account information (i.e. address and balance), current gas price, and block information.
[[common_stack_opcodes]]
Common Stack Operations:: Opcode instructions for stack and memory management:

----
POP     //Pop item off the stack
PUSH    //Push item on the stack
MLOAD   //Load item into memory
MSTORE  //Store item in memory
JUMP    //Alter the location of program counter (PC)
PC      //Program counter
MSIZE   //Active memory size
GAS     //Amount of available gas for transaction
DUP     //Stack item duplication
SWAP    //Stack item exchange operation
----

[[common_system_opcodes]]
Common System Operations:: Opcode instructions for the system executing the program:

:set nonu