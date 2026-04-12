Proyecto de Infraestructura de Red y Despliegue con FOG Project

Este repositorio contiene la documentación técnica y los archivos de configuración para la implantación de un sistema de despliegue masivo mediante FOG Project, junto con la gestión de la infraestructura de red necesaria para dar servicio en un entorno segmentado (multi-subred).
🚀 Descripción del Proyecto

El objetivo es configurar un entorno de red robusto utilizando Proxmox VE como hipervisor. El proyecto abarca desde la clonación por red (PXE) hasta el enrutamiento avanzado entre bridges y la gestión remota de energía (Wake On LAN) mediante escenarios simulados.
Componentes Principales:

    Servidor FOG (Ubuntu Server): Nodo maestro para la gestión centralizada de imágenes.

    Gateway (R1-Ubuntu / MikroTik): Configuración de routing con capacidades de DHCP-Relay y Forwarding.

    Clientes Multi-plataforma: Soporte de arranque dual para entornos Legacy BIOS y UEFI BIOS.

🛠️ Tecnologías y Servicios

He unificado "Servicios" y "Networking" para reflejar mejor cómo interactúan en la infraestructura:

    Sistemas y Virtualización: Proxmox VE, Ubuntu Server (con gestión de volúmenes LVM).

    Servicios de Despliegue: FOG Project (NFS, TFTP, FTP), DNSMASQ (ProxyDHCP).

    Infraestructura de Red: * Gestión de IP: ISC-DHCP-Server, DHCP-Relay.

        Routing & Tráfico: Netplan, IP Forwarding, Multicast (SMCroute).

        Control Remoto: Wake On LAN (Etherwake).

    Control de Versiones: Git / GitHub.

📂 Arquitectura de la Infraestructura

    Servidor FOG:

        IP Estática: 10.2.7.5/24.

        Almacenamiento escalable mediante LVM para el repositorio de imágenes.

    Configuración de Red (Inter-VLAN):

        DHCP-Relay: Intermediario para servir IPs en los bridges vmbr217, vmbr227 y vmbr237.

        ProxyDHCP: Implementación con DNSMASQ para coexistir con servidores DHCP preexistentes sin generar conflictos.

        Optimización Multicast: Configuración de rutas para despliegues masivos eficientes.

    Gestión de Clientes:

        Automatización de encendido mediante scripts WOL.

        Entrega dinámica de archivos de arranque: undionly.kpxe (Legacy) e ipxe.efi (UEFI).

🔧 Instalación y Configuración Rápida
Requisitos Previos

    Servidor Ubuntu Server 20.04/22.04 LTS.

    Acceso a los repositorios oficiales de FOG:
   

    git clone https://github.com/FOGProject/fogproject.git
