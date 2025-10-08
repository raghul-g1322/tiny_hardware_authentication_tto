<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a 4-digit hardware OTP (One-Time Password) authentication system entirely in digital logic.
An internal 16-bit Linear Feedback Shift Register (LFSR) continuously generates a pseudo-random 4-digit OTP.
The Finite State Machine (FSM) compares the OTP with user-entered digits and decides whether the user input matches the generated OTP.

The flow is as follows:

The LFSR generates a 16-bit (4-digit) random OTP.

The user enters each digit (4 bits) one by one using external input switches or buttons.

Each time a digit is entered, the user_latch signal is pulsed to store that digit.

After all four digits are entered, the FSM verifies the full user OTP against the LFSR-generated OTP.

The FSM then outputs one of three results:

L (Locked): Wrong OTP or max attempts reached.

U (Unlocked): Correct OTP entered.

E (Expired): OTP expired before entry.

The system visually shows results on 8 seven-segment displays:

Right 4 displays: Show the user-entered OTP.

Left 4 displays: Alternate (every 2 seconds) between showing

The generated LFSR OTP, and

Status message "A#-X" (A = attempt, # = attempt number, X = L/U/E).

The pos_edge modules detect button edges cleanly so that presses are registered only once per pulse.

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
