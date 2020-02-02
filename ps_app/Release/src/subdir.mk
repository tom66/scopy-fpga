################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
LD_SRCS += \
../src/lscript.ld 

C_SRCS += \
../src/acquire.c \
../src/fabric_config.c \
../src/hal.c \
../src/main.c \
../src/platform.c 

OBJS += \
./src/acquire.o \
./src/fabric_config.o \
./src/hal.o \
./src/main.o \
./src/platform.o 

C_DEPS += \
./src/acquire.d \
./src/fabric_config.d \
./src/hal.d \
./src/main.d \
./src/platform.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: ARM v7 gcc compiler'
	arm-none-eabi-gcc -DDEBUG -Wall -O2 -g -c -fmessage-length=0 -MT"$@" -mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard -IC:/Users/Tom/Documents/Projects/Scopy_MVP_Platform/scopy-fpga/main/export/main/sw/main/standalone_domain/bspinclude/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


