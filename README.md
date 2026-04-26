# 🚀 FOG Project: Infraestructura de Despliegue Masivo y Networking

[![FOG Project](https://img.shields.io/badge/Service-FOG--Project-blue)](https://fogproject.org/)
[![Ubuntu](https://img.shields.io/badge/OS-Ubuntu--Server-orange)](https://ubuntu.com/)
[![Hypervisor](https://img.shields.io/badge/Hypervisor-Proxmox--VE-white)](https://www.proxmox.com/)
[![Networking](https://img.shields.io/badge/Networking-DHCP--Relay%20%7C%20Multicast-green)](#)

Este repositorio contiene la documentación técnica y los archivos de configuración para la implantación de un sistema de despliegue masivo mediante **FOG Project**, junto con la gestión de la infraestructura de red necesaria para dar servicio en un entorno segmentado (múltiples subredes).

---

## 📋 Tabla de Contenidos
* [Descripción del Proyecto](#-descripción-del-proyecto)
* [Tecnologías y Servicios](#️-tecnologías-y-servicios)
* [Arquitectura de la Infraestructura](#-arquitectura-de-la-infraestructura)
* [Seguridad y Escalabilidad](#-seguridad-y-escalabilidad)
* [Instalación y Configuración](#-instalación-y-configuración-rápida)

---

## 🚀 Descripción del Proyecto

El objetivo principal es la configuración de un entorno de red robusto utilizando **Proxmox VE** como hipervisor. El proyecto abarca desde la clonación por red (PXE) hasta el enrutamiento avanzado entre subredes y la gestión remota de energía (**Wake On LAN**).

### Componentes Principales:
* **Servidor FOG (Ubuntu Server):** Nodo maestro encargado de la gestión centralizada de imágenes y base de datos de hosts.
* **Dispositivo de red (R1-Ubuntu / MikroTik):** Configuración de routing con capacidades de DHCP-Relay y Multicast.
* **Clientes Multi-plataforma:** Soporte de arranque dual para entornos Legacy BIOS (`undionly.kpxe`) y UEFI BIOS (`ipxe.efi`).

---

## 🛠️ Tecnologías y Servicios

| Capa | Tecnologías |
| :--- | :--- |
| **Sistemas y Virtualización** | Proxmox VE, Ubuntu Server, Gestión de volúmenes **LVM** |
| **Servicios de Despliegue** | FOG Project (NFS, TFTP, FTP) |
| **Gestión de IP** | ISC-DHCP-Server, DHCP-Relay, **DNSMASQ** (ProxyDHCP) |
| **Routing y Tráfico** | Netplan, IP Forwarding, Multicast (**SMCroute**) |
| **Control de Versiones** | Git / GitHub |

---

## 📂 Arquitectura de la Infraestructura

### 1. Servidor FOG
* **IP Estática:** `10.2.7.5/24`.
* **Almacenamiento:** Configuración expandible mediante **LVM** para el repositorio de imágenes.
* **DHCP:** Servidor configurado para dar soporte a múltiples subredes.

### 2. Configuración de Red (Inter-Bridge)
* **DHCP-Relay:** Configurado para servir direccionamiento a través de los bridges `vmbr217`, `vmbr227` y `vmbr237`.
* **ProxyDHCP:** Implementación con **DNSMASQ** para permitir el arranque PXE en subredes con servidores DHCP preexistentes.
* **Optimización Multicast:** Configuraciones para despliegues masivos eficientes sin saturación de banda.

### 3. Gestión de Clientes
* **Automatización:** Scripts personalizados para encendido remoto (`fog-wol-linux.sh`).
* **FOG Client & Snapins:** Gestión de software post-clonación y ejecución de scripts post-download.

---

## 🔒 Seguridad y Escalabilidad (Fase 2)

Como mejora de arquitectura, se ha integrado un stack de seguridad basado en **Docker**:
* **Nginx Proxy Manager:** Propuesta de Proxy Inverso para el cifrado SSL/TLS de la consola de administración.
* **Hardening:** Configuración de firewall **UFW** para el aislamiento de servicios críticos.
* **Optimización de Backups:** Corrección del error 401 en el script oficial de FOG mediante el uso nativo de `mysqldump`.

---

## 🔧 Instalación y Configuración Rápida

### Requisitos Previos
* Servidor Ubuntu Server 20.04/22.04 LTS actualizado.
* Acceso a red con capacidades de virtualización (Proxmox).

### Pasos iniciales
```bash
# Clonar repositorio oficial de FOG
git clone [https://github.com/FOGProject/fogproject.git](https://github.com/FOGProject/fogproject.git)

# Acceder al directorio del instalador
cd fogproject/bin

# Ejecutar el asistente de instalación
./installfog.sh
