
# Virtualization Feature Check Script

## Overview
This script is designed to provide a comprehensive check of various virtualization features available and enabled on a Linux system. It helps in determining the compatibility of the system for running virtualized environments efficiently by checking CPU types, hardware virtualization support, IOMMU support, and specific Intel and AMD virtualization technologies.

## Purpose
The main purpose of this script is to:
- Identify whether the CPU is manufactured by Intel or AMD.
- Verify if essential virtualization supports such as VT-x/AMD-V, IOMMU, SEV (for AMD), and TDX (for Intel) are enabled.
- Provide guidance on enabling these features if they are not currently active.

## Prerequisites
To use this script, ensure that you have the following installed:
- `grep`
- `awk`
- `lscpu` (usually pre-installed in most Linux distributions)
- `dmesg` access (requires root permissions)
- `virt-host-validate` (part of `libvirt-clients` package)

You may install `libvirt-clients` using the following command:
```bash
sudo apt install libvirt-clients
```

## Usage
To use this script, follow these steps:
1. **Download the script**: Download the script to your local machine.
2. **Make it executable**:
    ```bash
    chmod +x virt-check.sh
    ```
3. **Run the script**:
    ```bash
    ./virt-check.sh
    ```

Optional: If you encounter permission issues related to `dmesg`, consider running the script with `sudo`:
```bash
sudo ./virt-check.sh
```

## What the Script Checks
Here is a detailed description of what each check in the script does:

### CPU Manufacturer
- **Checks**: Whether the CPU is from Intel (`GenuineIntel`) or AMD (`AuthenticAMD`).
- **Purpose**: Determines subsequent checks relevant to the CPU type.

### Hardware Virtualization Support
- **Checks**: For the presence of `vmx` (Intel) or `svm` (AMD) in CPU flags.
- **Outputs**:
  - "VT-x (Intel Virtualization) enabled" or "AMD-V (AMD Virtualization) enabled" if applicable.
  - "Not applicable for AMD/Intel" if the wrong flag is detected considering the CPU type.
  - "Virtualization support not available for your CPU" if neither flag is found.

### General Virtualization Support via lscpu
- **Checks**: Output from the `lscpu` command for virtualization support.
- **Purpose**: Provides a user-friendly confirmation if virtualization is supported and enabled.

### IOMMU Support
- **Checks**: Kernel messages for IOMMU activation.
- **Outputs**:
  - "IOMMU support enabled in kernel" if IOMMU-related messages are found.
  - Guidance on enabling IOMMU if not found.

### Secure Encrypted Virtualization (SEV)
- **For**: AMD CPUs only.
- **Checks**: For the `sev` flag in CPU info.
- **Outputs**:
  - "AMD SEV enabled" if the flag is found.
  - Instructions for enabling SEV in BIOS if the flag is not found.

### Intel Trust Domain Extensions (TDX)
- **For**: Intel CPUs only.
- **Checks**: For the `tdx` flag in CPU info.
- **Outputs**:
  - "Intel TDX enabled" if the flag is found.
  - Instructions for enabling TDX in BIOS if the flag is not found.

### Kernel Command Line Checks for IOMMU
- **Checks**: Current kernel command line for `intel_iommu=on` or `amd_iommu=on`.
- **Outputs**:
  - Confirmation if IOMMU is enabled in the current kernel parameters.
  - Recommendation for checking BIOS settings and kernel parameters if not enabled.

### Virt-Host-Validate Execution
- **Checks**: Uses `virt-host-validate` to perform a comprehensive system check for virtualization capability.
- **Purpose**: Confirms system configuration is optimal for virtualization.

## Conclusion
This script is an essential tool for system administrators and enthusiasts who need to prepare a system for virtualization, providing quick diagnostics and actionable advice.
