################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/Collections-C/src/subdir.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
ELFSIZE += \
ps_app.elf.size \


# All Target
all:
	$(MAKE) --no-print-directory pre-build
	$(MAKE) --no-print-directory main-build

# Main-build Target
main-build: ps_app.elf secondary-outputs

# Tool invocations
ps_app.elf: $(OBJS) ../src/lscript.ld $(USER_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: ARM v7 gcc linker'
	arm-none-eabi-gcc -L"C:\Users\Tom\Documents\Projects\Scopy_MVP_Platform\scopy-fpga\main\ps7_cortexa9_0\standalone_domain\bsp\ps7_cortexa9_0\lib" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -Wl,-build-id=none -specs=Xilinx.spec -Wl,-Map=ps_app_gen.map --verbose -Wl,-T -Wl,../src/lscript.ld -LC:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/main/export/main/sw/main/standalone_domain/bsplib/lib -o "ps_app.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
	$(MAKE) --no-print-directory post-build

ps_app.elf.size: ps_app.elf
	@echo 'Invoking: ARM v7 Print Size'
	arm-none-eabi-size ps_app.elf  |tee "ps_app.elf.size"
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(EXECUTABLES)$(OBJS)$(S_UPPER_DEPS)$(C_DEPS)$(ELFSIZE) ps_app.elf
	-@echo ' '

pre-build:
	-a9-linaro-pre-build-step
	-@echo ' '

post-build:
	-@echo 'try to produce objectdump'
	-arm-none-eabi-objdump -d -t -S ../Release/ps_app.elf > ../Release/ps_app.lst
	-@echo ' '

secondary-outputs: $(ELFSIZE)

.PHONY: all clean dependents main-build pre-build post-build

-include ../makefile.targets
