################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/acq_ctrl.c \
../src/acq_hacks.c \
../src/acquire.c \
../src/clkwiz_interface.c \
../src/dma_bd.c \
../src/fabric_config.c \
../src/hal.c \
../src/main.c \
../src/mipi_csi.c \
../src/mipi_csi_hw.c \
../src/platform.c \
../src/spi.c \
../src/spi_commands.c \
../src/system_control.c \
../src/test_patterns.c \
../src/trigger.c 

OBJS += \
./src/acq_ctrl.o \
./src/acq_hacks.o \
./src/acquire.o \
./src/clkwiz_interface.o \
./src/dma_bd.o \
./src/fabric_config.o \
./src/hal.o \
./src/main.o \
./src/mipi_csi.o \
./src/mipi_csi_hw.o \
./src/platform.o \
./src/spi.o \
./src/spi_commands.o \
./src/system_control.o \
./src/test_patterns.o \
./src/trigger.o 

C_DEPS += \
./src/acq_ctrl.d \
./src/acq_hacks.d \
./src/acquire.d \
./src/clkwiz_interface.d \
./src/dma_bd.d \
./src/fabric_config.d \
./src/hal.d \
./src/main.d \
./src/mipi_csi.d \
./src/mipi_csi_hw.d \
./src/platform.d \
./src/spi.d \
./src/spi_commands.d \
./src/system_control.d \
./src/test_patterns.d \
./src/trigger.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -DDEBUG -Wall -O3 -g -IC:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/main/export/main/sw/main/standalone_domain/bspinclude/include -I"../.\src\Collections-C\src\include" -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -IC:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/main/export/main/sw/main/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


