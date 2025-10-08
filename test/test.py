# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0
"""
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
"""
# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge, FallingEdge

@cocotb.test()
async def test_otp_system(dut):
    dut._log.info("==== Starting OTP System Test ====")

    # Create 100 kHz clock
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.reset.value = 1
    dut.otp_latch.value = 0
    dut.user_latch.value = 0
    dut.user_in.value = 0

    await ClockCycles(dut.clk, 5)
    dut.reset.value = 0
    await ClockCycles(dut.clk, 5)
    dut.reset.value = 1
    dut._log.info("Reset done")

    # Capture initial LFSR display value
    initial_lfsr_out = int(dut.lfsr_out.value)
    dut._log.info(f"Initial LFSR display = {initial_lfsr_out:07b}")

    # Simulate user pressing otp_latch to capture new LFSR value
    dut.otp_latch.value = 1
    await ClockCycles(dut.clk, 1)
    dut.otp_latch.value = 0

    # Wait a few clock cycles and check if LFSR output changes
    await ClockCycles(dut.clk, 500)
    new_lfsr_out = int(dut.lfsr_out.value)
    dut._log.info(f"New LFSR display = {new_lfsr_out:07b}")
    assert new_lfsr_out != initial_lfsr_out, "LFSR output did not change after latch!"

    # Simulate user entering OTP (4 digits)
    for digit in [1, 2, 3, 4]:
        dut.user_in.value = digit
        dut.user_latch.value = 1
        await ClockCycles(dut.clk, 1)
        dut.user_latch.value = 0
        await ClockCycles(dut.clk, 5)

    dut._log.info("User entered 4 digits")

    # Wait for FSM to process comparison
    await ClockCycles(dut.clk, 1000)

    # Log the current FSM status outputs
    dut._log.info(f"unlock={dut.unlock.value}, lock={dut.lock.value}, expire={dut.expire.value}")

    # Verify at least one output became active
    assert (dut.unlock.value or dut.lock.value or dut.expire.value), "FSM did not update any status!"

    # Check toggling of 7-seg (simulate 2-sec toggle)
    # Assuming 100kHz clock → 2 sec = 200,000 cycles
    lfsr_display_1 = int(dut.lfsr_out.value)
    await ClockCycles(dut.clk, 200_000)
    lfsr_display_2 = int(dut.lfsr_out.value)
    dut._log.info(f"LFSR display toggled from {lfsr_display_1:07b} to {lfsr_display_2:07b}")
    assert lfsr_display_1 != lfsr_display_2, "LFSR display did not toggle after 2 seconds!"

    dut._log.info("==== OTP System Test PASSED ====")
