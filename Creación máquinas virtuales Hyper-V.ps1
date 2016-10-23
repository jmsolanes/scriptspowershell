function NuevaVM
{
    $nombreVM = $args[0]
    $plantillaVHDX = "D:\VMs\Plantillas\Windows2016coreplantilla.vhdx"
    $switch = "swExtern" # switch virtual donde conectar las máquinas virtuales.
    $MemoriaRAM = 2048MB # memoria RAM de la máquina virtual.
    $CPUs = 2 # número de procesadores virtuales

    $CarpetaVM = "d:\VMs\" + $nombreVM  # La carpeta que tendrá las subcarpetas y ficheros de la VM.
    $CarpetaVHDX = $CarpetaVM + "\Virtual Hard Disks\" # La carpeta donde se copiara el disco duro virtual.
    $ubicacionDisco = $CarpetaVHDX + $nombreVM + "_C.vhdx" # El nombre del disc duro virtual para la unidad C.

    if (!(Get-VMSwitch | Where-Object -Property Name -eq $switch).count -eq 1)
    {
       # El switch virtual no existe, se crea uno del tipo privado
       New-VMSwitch -Name $switch -SwitchType Private
       write-host("No existe el switch parametrizado, se crea uno de privado llamado: " + $switch) -foregroundColor Green
    }

    New-VM -Name $nombreVM -MemoryStartupBytes $MemoriaRAM -SwitchName $switch -Generation 2
    Move-VMStorage -VM (get-vm $nombreVM) -DestinationStoragePath $CarpetaVM
    set-vm $nombreVM -StaticMemory -ProcessorCount $CPUs -AutomaticStartAction Start -AutomaticStartDelay 10 -AutomaticStopAction ShutDown -CheckpointType Disabled
    Disable-VMIntegrationService -VMName $nombreVM -name *time*
    New-Item $CarpetaVHDX -type directory
    Copy-item $plantillaVHDX -Destination $CarpetaVHDX
    Rename-Item ($CarpetaVHDX + "Windows2016coreplantilla.vhdx") $ubicacionDisco
    Add-VMHardDiskDrive -VMName $nombreVM -Path $ubicacionDisco -ControllerType SCSI
    Set-VMFirmware -VMName $nombreVM -BootOrder (Get-VMHardDiskDrive -VMName $nombreVM)
    start-vm (Get-VM $nombreVM)
    vmconnect localhost $nombreVM
}

function CrearEntornoAppWeb
{
   param([string[]] $VMs)
   foreach ($VM in $VMs)
   {
      write-host("Creando máquina virtual: " + $VM) -ForegroundColor Green
      NuevaVM $VM
   }
}