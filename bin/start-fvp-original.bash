#!/bin/bash

export ARTIFACTS="/workspaces/artifacts"
export LINUX_BASE_ADDR="0x84000000"
export INITRD_BASE_ADDR="0x83000000"

screen -dmS FVP -t 'FVP' /opt/fvp/Base_RevC_AEMvA_pkg/models/Linux64*/FVP_Base_RevC-2xAEMvA \
		-C bp.refcounter.non_arch_start_at_default=1 \
		-C bp.refcounter.use_real_time=0 \
		-C bp.ve_sysregs.exit_on_shutdown=1 \
		-C cache_state_modelled=0 \
		-C bp.dram_size=2 \
		-C bp.dram_metadata.is_enabled=1 \
		-C bp.secure_memory=1 \
		-C cluster0.NUM_CORES=4 \
		-C cluster0.PA_SIZE=48 \
		-C cluster0.ecv_support_level=2 \
		-C cluster0.gicv3.cpuintf-mmap-access-level=2 \
		-C cluster0.gicv3.without-DS-support=1 \
		-C cluster0.gicv4.mask-virtual-interrupt=1 \
		-C cluster0.has_arm_v8-6=1 \
		-C cluster0.has_amu=1 \
		-C cluster0.has_branch_target_exception=1 \
		-C cluster0.rme_support_level=2 \
		-C cluster0.has_rndr=1 \
		-C cluster0.has_v8_7_pmu_extension=2 \
		-C cluster0.max_32bit_el=-1 \
		-C cluster0.restriction_on_speculative_execution=2 \
		-C cluster0.restriction_on_speculative_execution_aarch32=2 \
		-C cluster0.stage12_tlb_size=1024 \
		-C cluster0.check_memory_attributes=0 \
		-C pci.pci_smmuv3.mmu.SMMU_AIDR=2 \
		-C pci.pci_smmuv3.mmu.SMMU_IDR0=0x0046123B \
		-C pci.pci_smmuv3.mmu.SMMU_IDR1=0x00600002 \
		-C pci.pci_smmuv3.mmu.SMMU_IDR3=0x1714 \
		-C pci.pci_smmuv3.mmu.SMMU_IDR5=0xFFFF0475 \
		-C pci.pci_smmuv3.mmu.SMMU_S_IDR1=0xA0000002 \
		-C pci.pci_smmuv3.mmu.SMMU_S_IDR2=0 \
		-C pci.pci_smmuv3.mmu.SMMU_S_IDR3=0 \
		-C pci.pci_smmuv3.mmu.SMMU_ROOT_IDR0=3 \
		-C pci.pci_smmuv3.mmu.SMMU_ROOT_IIDR=0x43B \
		-C pci.pci_smmuv3.mmu.root_register_page_offset=0x20000 \
		-C pctl.startup=0.0.0.0 \
		-C bp.smsc_91c111.enabled=1 \
		-C bp.hostbridge.userNetworking=1 \
		-C bp.hostbridge.userNetPorts=17010=17010 \
		-C bp.pl011_uart0.uart_enable=1 \
		-C bp.pl011_uart1.uart_enable=1 \
		-C bp.pl011_uart2.uart_enable=1 \
		-C bp.pl011_uart3.uart_enable=1 \
		-C bp.terminal_0.terminal_command="screen -dmS Linux  -t 'Linux' telnet localhost %port" \
		-C bp.terminal_1.terminal_command="screen -dmS RMM -t 'RMM' telnet localhost %port" \
		-C bp.terminal_2.terminal_command="screen -dmS Debug -t 'Debug' telnet localhost %port" \
		-C bp.terminal_3.terminal_command="screen -dmS Unknown -t 'Unknown' telnet localhost %port" \
		-C bp.secureflashloader.fname=$ARTIFACTS/bl1-linux.bin \
		-C bp.flashloader0.fname=$ARTIFACTS/fip-linux.bin \
		--data cluster0.cpu0=$ARTIFACTS/Image@$LINUX_BASE_ADDR \
        --data cluster0.cpu0=$ARTIFACTS/initramfs.cpio@$INITRD_BASE_ADDR \
		-C bp.virtiop9device.root_path=/work

sleep 5
