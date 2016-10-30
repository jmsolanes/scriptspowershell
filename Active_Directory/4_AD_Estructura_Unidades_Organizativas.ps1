# Variables generales
$dominioLDAP = "DC=jmsolanes,DC=local"

# Función para crear un nuevo Grupo de Seguridad
function NuevoGrupoSeguridad
{
   $NombreGrupo = $Args[0]
   $NombreOU = $Args[1]
   $dominioLDAP = $Args[2]
   $rutaOU = ("OU="+$NombreOU+","+$dominioLDAP)
   if (Get-ADGroup -Filter {SamAccountName -eq $NombreGrupo})
   {
      write-host ("El grupo de seguridad " + $NombreGrupo + " ya existe.") -ForegroundColor Red
   }
   else
   {
      New-ADGroup -DisplayName $NombreGrupo -Name $NombreGrupo -GroupScope DomainLocal -GroupCategory Security -Path $rutaOU
   }
}

# Función para crear un nuevo Usuario, si se crea la OU Administradores. Lo añade automáticamente a los Grupos de Administradores de SQL y SharePoint.
function NuevoUsuario
{
   $NombreUsuario=$Args[0]
   $NombreLogon=$Args[1]
   $NombreOU = $Args[2]
   $dominioLDAP = $Args[3]
   $rutaOU = ($NombreOU+","+$dominioLDAP)
   if (Get-ADUser -Filter {SamAccountName -eq $NombreLogon})
   {
      write-host ("La cuenta de usuario " + $NombreLogon + " ya existe.") -ForegroundColor Red
   }
   else
   {
      write-host("Creando el usuario " + $NombreLogon + " en la unidad organizativa "+$rutaOU) -ForegroundColor Green
      New-ADUser -DisplayName $NombreUsuario -Name $NombreLogon -UserPrincipalName $NombreLogon -Enabled:$true -Path $rutaOU -AccountPassword (ConvertTo-SecureString -string "P@ssw0rd" -AsPlainText -Force) -ChangePasswordAtLogon:$True
   }
   if ($NombreOU="Administradores")
    {
    Add-ADGroupMember -Identity "Administradores de SQL Server" -Members $NombreLogon
    Add-ADGroupMember -Identity "Administradores de SharePoint" -Members $NombreLogon
    }
}

# Función principal para crear la estructura y a partir de ella ir creando los grupos de seguridad y usuarios.
function CreaEstructura
{
   $NombreOU = $args[0]
   $dominioLDAP = $args[1]
   $rutaOU = ("OU="+$NombreOU+","+$dominioLDAP)
   Write-Host ("Creando Unidad Organizativa: " + $rutaOU) -ForegroundColor Yellow
   if ([adsi]::Exists(("LDAP://"+$rutaOU))) 
   {
        write-host ("La Unidad Organizativa " + $NombreOU + " ya existe.") -ForegroundColor Red
   } 
   else
   {
        write-host ("Creando la OU "+$NombreOU+","+$dominioLDAP) -ForegroundColor Green
        new-ADOrganizationalUnit -DisplayName $NombreOU -Name $NombreOU -path $dominioLDAP
   }

   if ($NombreOU -eq "GRUPOS DE SEGURIDAD")
   {
        write-host ("Estoy en la OU "+$NombreOU+" creando los grupos de seguridad correspondientes.") -ForegroundColor Green
        NuevoGrupoSeguridad "Usuarios Wi-Fi" $NombreOU $dominioLDAP
        NuevoGrupoSeguridad "Usuarios VPN" $NombreOU $dominioLDAP
        NuevoGrupoSeguridad "Técnicos de HelpDesk" $NombreOU $dominioLDAP
        NuevoGrupoSeguridad "Administradores de SQL Server" $NombreOU $dominioLDAP
        NuevoGrupoSeguridad "Administradores de SharePoint" $NombreOU $dominioLDAP
   }

   if ($NombreOU -eq "Administradores")
   {
       write-host ("Estoy en la OU "+$NombreOU+"; creando los usuarios correspondientes.") -ForegroundColor Green
       NuevoUsuario "Operador" "Operador" ("OU="+$NombreOU) $dominioLDAP
       NuevoUsuario "Administrador Josep Solanes" "adminjmsolanes" ("OU="+$NombreOU) $dominioLDAP
   }

}

# Ejecutamos la función principal con los nombres de las diferentes OUs y su ubicación.
CreaEstructura "GRUPOS DE SEGURIDAD" $dominioLDAP
CreaEstructura "USUARIOS" $dominioLDAP
CreaEstructura "Administradores" ("OU=USUARIOS,"+$dominioLDAP)
CreaEstructura "Servicios" ("OU=USUARIOS,"+$dominioLDAP)
CreaEstructura "Empresa" ("OU=USUARIOS,"+$dominioLDAP)
CreaEstructura "Externos" ("OU=USUARIOS,"+$dominioLDAP)
CreaEstructura "EQUIPOS" $dominioLDAP
CreaEstructura "Estaciones de Trabajo" ("OU=EQUIPOS,"+$dominioLDAP)
CreaEstructura "Móviles" ("OU=EQUIPOS,"+$dominioLDAP)
CreaEstructura "VDIs" ("OU=EQUIPOS,"+$dominioLDAP)
CreaEstructura "Servidores miembros" ("OU=EQUIPOS,"+$dominioLDAP)
CreaEstructura "NAS" ("OU=Servidores miembros,OU=EQUIPOS,"+$dominioLDAP)
CreaEstructura "Hipervisores" ("OU=Servidores miembros,OU=EQUIPOS,"+$dominioLDAP)
CreaEstructura "Clústeres" ("OU=Servidores miembros,OU=EQUIPOS,"+$dominioLDAP)