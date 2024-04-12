#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Help message function
usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  -h, --help      display this help message and exit"
    echo "This script checks for various virtualization features in the system."
}

# Exit if help is requested
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    usage
    exit 0
fi

# Function to check for command availability and suggest installation
check_command() {
    local cmd=$1
    local package=${2:-$1}
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}$cmd is not installed.${NC}"
        echo "Install it by running: ${GREEN}sudo apt install $package${NC}"
    else
        echo "$cmd is installed, continuing with checks..."
    fi
}

# Print the CPU type
cpu_type=$(awk -F ': ' '/vendor_id/{print $2; exit}' /proc/cpuinfo)
if [[ "$cpu_type" == "GenuineIntel" ]]; then
    echo "Intel Processor Detected"
    cpu="Intel"
elif [[ "$cpu_type" == "AuthenticAMD" ]]; then
    echo "AMD Processor Detected"
    cpu="AMD"
else
    echo "Unknown Processor Type"
    cpu="Unknown"
fi

echo "----------------------------"

# Check for virtualization support
echo "Checking for Hardware Virtualization Support:"
if grep -E 'vmx|svm' /proc/cpuinfo &> /dev/null; then
    if grep -q 'vmx' /proc/cpuinfo; then
        if [ "$cpu" == "AMD" ]; then
            echo "Not applicable for AMD."
        else
            echo "${GREEN}VT-x (Intel Virtualization) enabled.${NC}"
        fi
    fi
    if grep -q 'svm' /proc/cpuinfo; then
        if [ "$cpu" == "Intel" ]; then
            echo "Not applicable for Intel."
        else
            echo "${GREEN}AMD-V (AMD Virtualization) enabled.${NC}"
        fi
    fi
else
    echo "${RED}Virtualization support not available for your CPU or disabled in BIOS.${NC}"
fi

echo "----------------------------"

# General Virtualization Support via lscpu
check_command "lscpu" "util-linux"
echo "General Virtualization Support:"
lscpu_output=$(lscpu | grep 'Virtualization')
if [[ -n "$lscpu_output" ]]; then
    echo -e "${GREEN}$lscpu_output${NC}"
else
    echo -e "${RED}No virtualization support found in lscpu output.${NC}"
fi

echo "----------------------------"

# Check for IOMMU support
echo "Checking for IOMMU Support:"
dmesg | grep -i 'IOMMU' &> /dev/null
if [ $? -eq 0 ]; then
    echo "${GREEN}IOMMU support enabled in kernel.${NC}"
else
    echo "${RED}IOMMU support disabled. Add intel_iommu=on or amd_iommu=on to kernel cmdline.${NC}"
    echo "For instructions: How do I add parameters to the Linux kernel command line?"
fi

echo "----------------------------"

# Secure Encrypted Virtualization (SEV)
echo "Checking for Secure Encrypted Virtualization (SEV):"
if [ "$cpu" == "AMD" ]; then
    grep --color -o 'sev' /proc/cpuinfo &> /dev/null
    if [ $? -eq 0 ]; then
        echo "${GREEN}AMD SEV enabled.${NC}"
    else
        echo "${RED}AMD SEV not available or disabled. Must be enabled in BIOS.${NC}"
        echo "For instructions: How do I enable SEV in the BIOS?"
    fi
else
    echo "Not applicable for Intel."
fi

echo "----------------------------"

# Intel Trust Domain Extensions (TDX)
echo "Checking for Intel Trust Domain Extensions (TDX):"
if [ "$cpu" == "Intel" ]; then
    grep --color -o 'tdx' /proc/cpuinfo &> /dev/null
    if [ $? -eq 0 ]; then
        echo "${GREEN}Intel TDX enabled.${NC}"
    else
        echo "${RED}Intel TDX not available or disabled. Must be enabled in BIOS.${NC}"
        echo "For instructions: How do I enable TDX in the BIOS?"
    fi
else
    echo "Not applicable for AMD."
fi

echo "----------------------------"

# Kernel Command Line Checks for IOMMU
echo "Kernel Command Line Checks for IOMMU:"
cmdline=$(cat /proc/cmdline)
if [[ "$cmdline" == *"intel_iommu=on"* ]] || [[ "$cmdline" == *"amd_iommu=on"* ]]; then
    echo "${GREEN}IOMMU is enabled in the current kernel parameters.${NC}"
else
    echo "${RED}IOMMU is not enabled. Recommend checking BIOS settings and kernel parameters.${NC}"
fi

echo "----------------------------"

# Run virt-host-validate to check virtualization capabilities if available
check_command "virt-host-validate" "libvirt-clients"
echo "Running virt-host-validate to check hardware virtualization capabilities..."
virt-host-validate
