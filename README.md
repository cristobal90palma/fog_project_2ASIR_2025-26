# Proyecto de Infraestructura de Red y Despliegue con FOG Project

Este repositorio contiene la documentación técnica y los archivos de configuración para la implantación de un sistema de despliegue masivo mediante **FOG Project**, junto con la gestión de la infraestructura de red necesaria para dar servicio en un entorno segmentado (múltiples subredes).

## 🚀 Descripción del Proyecto

El objetivo principal es la configuración de un entorno de red robusto utilizando **Proxmox VE** como hipervisor. El proyecto abarca desde la captura, gestión y despliegue de imágenes de Sistemas Operativos por red (PXE) hasta el enrutamiento avanzado entre subredes (bridges) y la gestión remota (**Wake On LAN**) —en este caso de manera simulada—.

### Componentes Principales:

* **Servidor FOG (Ubuntu Server):** Servidor encargado de la gestión centralizada de imágenes y base de datos de hosts.
* **Dispositivo de red (R1-Ubuntu):** Configuración de routing con capacidades de DHCP-Relay, Multicast y redirección de señal Wake On LAN.
* **MikroTik:** Configuración de routing con capacidades de DHCP-Relay y Multicast. Se han implementado dos métodos para la gestión de energía:
    1. Uso del propio MikroTik como agente WOL.
    2. Uso de un *Jump Box* para emitir las señales WOL desde el interior de la propia subred.
* **Clientes Multi-plataforma:** Soporte de arranque dual para entornos Legacy BIOS (`undionly.kpxe`) y UEFI BIOS (`ipxe.efi`).

## 🛠️ Tecnologías y Servicios

Se han integrado diversas tecnologías para garantizar la operabilidad de la red:

* **Sistemas y Virtualización:** Proxmox VE, Ubuntu Server (con gestión de volúmenes **LVM** para almacenamiento escalable).
* **Servicios de Despliegue:** FOG Project (NFS y TFTP).
* **Infraestructura de Red:**
    * **Routing:** ISC-DHCP-Server, DHCP-Relay, IP Forwarding, Multicast (**SMCroute**).
    * **ProxyDHCP:** Implementación con **DNSMASQ**.
    * **Wake On LAN:** Mediante servidor FOG o agentes remotos.
* **Control de Versiones:** Git / GitHub.

## 📂 Arquitectura de la Infraestructura

### 1. Servidor FOG
* **IP Estática:** `10.2.7.5/24`.
* Configuración de almacenamiento expandible mediante **LVM** para el repositorio de imágenes.
* Servidor DHCP configurado para dar servicio a múltiples subredes.

### 2. Configuración de Red (Inter-Bridge)
* **DHCP-Relay:** Configurado para servir direccionamiento a través de los bridges `vmbr217`, `vmbr227` y `vmbr237`.
* **ProxyDHCP:** Implementación con **DNSMASQ** para permitir el arranque PXE en subredes donde ya existe un servidor DHCP ajeno.
* **Optimización Multicast:** Configuraciones para despliegues masivos eficientes sin saturar el ancho de banda.

### 3. Gestión de Clientes
* **Automatización:** Encendido mediante scripts personalizados (`fog-wol-linux.sh`).
* **Diferenciación de binarios de arranque:** `undionly.kpxe` para sistemas Legacy y `ipxe.efi` para sistemas UEFI.
* **FOG Client & Snapins:** Gestión centralizada de software y ejecución de scripts *post-download*.
