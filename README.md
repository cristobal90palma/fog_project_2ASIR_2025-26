# Proyecto de Infraestructura de Red y Despliegue con FOG Project

Este repositorio contiene la documentación técnica y los archivos de configuración para la implantación de un sistema de despliegue masivo mediante **FOG Project**, junto con la gestión de la infraestructura de red necesaria para dar servicio en un entorno segmentado (multiples subredes).

## 🚀 Descripción del Proyecto

El objetivo principal es la configuración de un entorno de red robusto utilizando **Proxmox VE** como hipervisor. El proyecto abarca desde la clonación por red (PXE) hasta el enrutamiento avanzado entre subredes (bridges) y la gestión remota de energía (**Wake On LAN**) --> En este caso de manera simulada.

### Componentes Principales:
- **Servidor FOG (Ubuntu Server):** Nodo maestro encargado de la gestión centralizada de imágenes y base de datos de hosts.
- **Dispositivo de red (R1-Ubuntu / MikroTik):** Configuración de routing con capacidades de DHCP-Relay y Multicast.
- **Clientes Multi-plataforma:** Soporte de arranque dual para entornos Legacy BIOS y UEFI BIOS.

## 🛠️ Tecnologías y Servicios

Se han integrado diversas tecnológicas para garantizar la operabilidad de la red:

* **Sistemas y Virtualización:** Proxmox VE, Ubuntu Server (con gestión de volúmenes **LVM** para almacenamiento escalable).
* **Servicios de Despliegue:** FOG Project (NFS, TFTP, FTP).
* **Infraestructura de Red:**
    * **Gestión de IP:** ISC-DHCP-Server, DHCP-Relay.
    * **DNSMASQ** (configurado como ProxyDHCP).
    * **Routing & Tráfico:** Netplan, IP Forwarding, Multicast (**SMCroute**).
    * **Wake On LAN:** mediante servidor FOG o agentes remotos.
* **Control de Versiones:** Git / GitHub.

## 📂 Arquitectura de la Infraestructura

1.  **Servidor FOG:**
    * IP Estática: `10.2.7.5/24`.
    * Configuración de almacenamiento expandible mediante LVM para el repositorio de imágenes.
    * Servidor DHCP configurado para múltiples subredes.

2.  **Configuración de Red (Inter-Bridge):**
    * **DHCP-Relay:** Configurado para servir direccionamiento a través de los bridges `vmbr217`, `vmbr227` y `vmbr237`.
    * **ProxyDHCP:** Implementación con DNSMASQ para permitir el arranque PXE en subredes donde ya existe un servidor DHCP ajeno.
    * **Optimización Multicast:** Configuraciones para despliegues masivos eficientes sin saturar el ancho de banda.

3.  **Gestión de Clientes:**
    * Automatización de encendido mediante scripts personalizados (`fog-wol-linux.sh`).
    * Diferenciación de binarios de arranque: `undionly.kpxe` para Legacy y `ipxe.efi` para sistemas UEFI.

## 🔧 Instalación y Configuración Rápida

### Requisitos Previos
- Servidor Ubuntu Server 20.04/22.04 LTS actualizado.
- Acceso al repositorio oficial de FOG: git clone https://github.com/FOGProject/fogproject.git
