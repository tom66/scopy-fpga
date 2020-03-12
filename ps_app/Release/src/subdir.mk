################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/acq_hacks.c \
../src/acquire.c \
../src/clkwiz_interface.c \
../src/dma_gearbox.c \
../src/fabric_config.c \
../src/hal.c \
../src/main.c \
../src/mipi_csi.c \
../src/mipi_csi_hacks.c \
../src/platform.c 

OBJS += \
./src/acq_hacks.o \
./src/acquire.o \
./src/clkwiz_interface.o \
./src/dma_gearbox.o \
./src/fabric_config.o \
./src/hal.o \
./src/main.o \
./src/mipi_csi.o \
./src/mipi_csi_hacks.o \
./src/platform.o 

C_DEPS += \
./src/acq_hacks.d \
./src/acquire.d \
./src/clkwiz_interface.d \
./src/dma_gearbox.d \
./src/fabric_config.d \
./src/hal.d \
./src/main.d \
./src/mipi_csi.d \
./src/mipi_csi_hacks.d \
./src/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -DDEBUG -Wall -O3 -g -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -IC:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/main/export/main/sw/main/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


