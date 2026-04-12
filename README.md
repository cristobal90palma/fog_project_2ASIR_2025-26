from weasyprint import HTML

# Content for the README.md
readme_content = """# Proyecto de Infraestructura de Red y Despliegue con FOG Project

Este repositorio contiene la documentación técnica y los archivos de configuración para la implementación de una infraestructura de red avanzada, centrada en el despliegue masivo de equipos mediante **FOG Project**, gestión de subredes y servicios de red críticos.

## 🚀 Descripción del Proyecto

El objetivo principal es la configuración de un entorno de red segmentado utilizando **Proxmox** como hipervisor, donde se gestionan servicios de clonación por red (PXE), encaminamiento entre VLANs, y gestión remota de energía (Wake On LAN).

### Componentes Principales:
- **Servidor FOG (Ubuntu):** Nodo maestro para la gestión de imágenes y despliegue.
- **R1-Ubuntu / Mikrotik:** Configuración de Router con capacidades de DHCP-Relay y Forwarding.
- **Clientes Multi-plataforma:** Soporte para arranque en entornos Legacy BIOS y UEFI BIOS.

## 🛠️ Tecnologías Utilizadas

- **Hipervisor:** Proxmox VE
- **SO Servidor:** Ubuntu Server (LVM configurado)
- **Servicios de Red:** ISC-DHCP-Server, DNSMASQ (ProxyDHCP), NFS, TFTP.
- **Networking:** Netplan, IP Forwarding, Multicast (SMCroute), DHCP-Relay.
- **Herramientas:** FOG Project, Etherwake, Git.

## 📂 Estructura de la Infraestructura

1.  **Servidor FOG:**
    - IP Estática: `10.2.7.5/24`
    - Configuración de almacenamiento expandible mediante LVM.
    - Repositorio de imágenes centralizado.

2.  **Configuración de Red:**
    - **DHCP-Relay:** Configurado para servir IPs a través de diferentes bridges (`vmbr207`, `vmbr217`, etc.).
    - **Multicast:** Implementación de rutas específicas para optimizar la clonación masiva sin saturar la red.
    - **DNSMASQ:** Configuración de ProxyDHCP para coexistencia con otros servidores DHCP en la misma subred.

3.  **Gestión de Clientes:**
    - Scripts de automatización para **Wake On LAN (WOL)**.
    - Diferenciación de archivos de arranque (`undionly.kpxe` para Legacy y `ipxe.efi` para UEFI).

## 🔧 Instalación y Configuración Rápida

### Requisitos Previos
- Servidor Ubuntu actualizado.
- Repositorio de FOG clonado:
