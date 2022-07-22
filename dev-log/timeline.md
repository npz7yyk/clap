# Timeline

## 2022-07-22

Test func_lab7 passed.

## 2022-07-20

Test func_lab6 passed.

## 2022-07-19

Test #6 fully passed.

Subtasks n1 to n32 in test func_lab6 passed.

## 2022-07-18

Test func_lab3 passed, with `BUS_DELAY=n`.

Test func_lab3 passed.

Test func_lab4 passed.

Subtasks n1 to n29 in test func_lab6 passed.

## 2022-07-17

Manage to run chiplab's simulation test.

Pass subtasks n1 to n13 in test func_lab3 in chiplab, with `BUS_DELAY=n`.

## 2022-07-16

Test #6 passed, but the branch predictor does not work as expected.

Replace Xilinx's crossbar IP with Alex Forencich's AXI interconnect.

Test #5 passed.

Attempt but fail to run chiplab's simulation test.

## 2022-07-15

Replace the free AXI crossbar with Xilinx's crossbar IP.

~~Test #5 passed.~~ We mistakenly thought we had passed test #5.

## 2022-07-14

Test #3 (ALU instructions without data hazards) and test #4 (ALU instructions with data hazards) passed.

## 2022-07-12

Complete the L1 data cache.

Import a *free* (自由, libre) AXI crossbar of Alex Forencich's.

Connect the AXI crossbar and the D-cache(16KiB, 4-way set associative, 64B per line, LRU, write-back, write-allocation).

Complete the branch predictor (2-bit state code, 2-bit history code, 4-way branch target buffer).

## 2022-07-11

Complete executing unit and the minimal runnable version of the branch predictor (2-bit state code, 2-bit local history code, 1-way branch target buffer); connect them with other parts of the CPU.

Add test #2 (an assembly code containing all instructions in `loongarch32r`)

## 2022-07-07

Modify the executing unit written for the former out of order CPU, and import it.

Complete the L1 instruction cache (16KiB, 4-way set associative, 64B per line, LRU replacing strategy).

Attempt to connect PC, I-cache, decoder and issue unit.

Add our own test #1 (a buddy sort C program, almost useless).

## 2022-07-05

Import the decoder from the former out of order CPU.

## 2022-07-04

Create the new repository. 
