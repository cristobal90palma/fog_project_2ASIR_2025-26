# Proyecto de Infraestructura de Red y Despliegue Centralizado con FOG Project

[![Licencia](https://img.shields.io/badge/Licencia-GPLv3-blue.svg)](LICENSE)
[![Tecnología](https://img.shields.io/badge/Tecnología-FOG%20Project%20%7C%20Proxmox%20%7C%20Ubuntu-green)]()

Repositorio con la documentación técnica completa y los archivos de configuración para la **implantación de un sistema de despliegue masivo y automatizado de sistemas operativos** basado en **FOG Project**, integrado en una red segmentada (múltiples subredes/VLANs).

---

## 🚀 Descripción del Proyecto

El objetivo principal es diseñar e implementar una **solución centralizada, eficiente y automatizada** para la captura, gestión y despliegue de imágenes de sistemas operativos en entornos educativos/empresariales. El proyecto resuelve las deficiencias de los métodos manuales o basados en CLI (como Clonezilla), ofreciendo:

- **Arranque PXE** en múltiples subredes mediante técnicas avanzadas de red.
- **Despliegues masivos optimizados** con **Multicast (UDPcast)**.
- **Automatización post-despliegue** "Zero Touch" (configuración, software y validación de licencias).
- **Monitorización proactiva** con alertas en tiempo real (Grafana + Telegram).
- **Recuperación ante desastres** mediante una estrategia robusta de backups y migración.

### Componentes Principales

| Componente | Rol / Función Clave |
| :--- | :--- |
| **Servidor FOG (Ubuntu 24.04 LTS)** | Gestión centralizada de imágenes, inventario de hosts y orquestación de tareas (captura/despliegue). |
| **R1-Ubuntu (Router)** | Dispositivo de red L3 que gestiona el enrutamiento, **DHCP-Relay**, **Multicast (smcroute)** y reenvío de **Wake-on-LAN** entre subredes. |
| **Router MikroTik** | Alternativa de router. Configurado con **IGMP Proxy** (Multicast) y scripts SSH para actuar como **agente proxy WOL**. |
| **Jump Box (Linux)** | Dispositivo auxiliar en una subred remota que emite señales WOL cuando el servidor FOG no puede hacerlo directamente. |
| **Clientes (BIOS/UEFI)** | Equipos finales (virtuales/físicos) configurados para arranque PXE y compatibles con Wake-on-LAN. |
| **Sistema de Monitorización** | Stack **Prometheus + Grafana** en un servidor independiente. Alertas vía Telegram (caída de servicios, saturación de disco). |

---

## 🛠️ Tecnologías y Servicios Implementados

### Infraestructura y Virtualización
- **Proxmox VE:** Hipervisor principal para la virtualización de servidores y clientes.
- **Ubuntu Server 24.04.3 LTS:** Sistema operativo base.
- **LVM (Logical Volume Manager):** Para ampliación dinámica y flexible del almacenamiento de imágenes.

### Servicios de Despliegue y Red
- **FOG Project (v1.5.x):** Núcleo del sistema (clonación, gestión).
- **DNSMASQ:** ProxyDHCP para entornos con servidor DHCP preexistente.
- **ISC DHCP Server:** Servidor DHCP para subredes gestionadas por el proyecto.
- **TFTP & NFS:** Protocolos para el arranque PXE y la transferencia de imágenes.
- **SMCroute:** Enrutamiento estático de tráfico **Multicast** entre subredes.
- **IGMP Proxy (MikroTik):** Alternativa para enrutamiento multicast en routers propietarios.

### Automatización y Gestión Post-Despliegue
- **Postdownload Scripts (Bash):** Inyección de `unattend.xml` y personalización pre-arranque.
- **FOG Client:** Agente en Windows para gestión remota y ejecución de tareas.
- **Snapins (PowerShell + Chocolatey):** Instalación de software (ej. Notepad++), activación de licencias y scripts personalizados.
- **Wake-on-LAN:** Scripts `fog-wakeup-mikrotik.sh` y `fog-wol-linux.sh` para encendido remoto automatizado.

### Seguridad y Alta Disponibilidad
- **UFW (Uncomplicated Firewall):** Política de mínimo privilegio.
- **Acceso SSH por llave Ed25519:** Deshabilitado acceso root y autenticación por contraseña.
- **Backups Automáticos:** Script oficial de FOG corregido (`mysqldump` en lugar de `wget`). Almacenamiento remoto vía **NFS**.
- **Monitorización:** Prometheus, Grafana, Blackbox Exporter. Alertas en Telegram ante fallos críticos (Apache, MariaDB, Multicast Manager).

---

## 📂 Estructura del Proyecto y Arquitectura

### Diagrama de Red Simplificado

[ Internet ]
│
[ Proxmox01 ]
│
┌────────────┼────────────┐
│ │ │
[Subred Gestión] [R1-Ubuntu] [Router MikroTik]
10.2.7.0/24 │ │
│ ┌─────┼─────┐ ┌─────┼─────┐
[Servidor FOG] │ │ │ │ │ │
10.2.7.5 [Aula1][Aula2][Aula3] ...
172.18.10.0/24, etc.


### Hitos Técnicos Destacados

1.  **Configuración de red avanzada:** Enrutamiento PXE y tráfico multicast entre subredes (descubrimiento del grupo `233.254.7.5` para `udpcast`).
2.  **ProxyDHCP con DNSMASQ:** Solución limpia para coexistir con el DHCP del centro sin modificarlo.
3.  **Automatización Zero Touch:** Integración exitosa de `unattend.xml`, scripts postdownload y Snapins (validado en `PR-AUT-004`).
4.  **Wake-on-LAN entre subredes:** Dos métodos funcionales (MikroTik como proxy y Jump Box Linux).
5.  **Monitorización y backup:** Sistema de alertas proactivo (Telegram) y migración completa a un nuevo servidor (`10.2.7.6`) con recuperación total de datos y configuración.

---

## 🗂️ Contenido del Repositorio

- `/FOG_Server/`: Archivos de configuración del servidor Ubuntu/FOG.
    - `etc/`: Configuraciones de DHCP, DNSMASQ, red (netplan), etc.
    - `scripts/`: Scripts personalizados (WOL, multicast, etc.).
    - `images/postdownloadscripts/`: Scripts de personalización post-despliegue (`unattend.xml`, `patch_unattend.sh`).
- `/Mikrotik/`: Configuración exportada del router (`mikrotik_config.rsc`).
- `/Documentacion/`: Capturas, diagramas y ficheros de respaldo.
- `Fases_Proyecto_FOG.mpp`: Planificación temporal del proyecto (Microsoft Project).

---

## ✅ Pruebas Clave Realizadas

| ID Prueba | Descripción | Estado |
| :--- | :--- | :--- |
| `PR-PXE-001/2` | Arranque PXE en subredes diferentes (Legacy/UEFI) | ✅ Superada |
| `PR-RED-001/3` | DHCP-Relay y enrutamiento en R1-Ubuntu y MikroTik | ✅ Superada |
| `PR-DES-006` | Despliegue Multicast a equipos en tres subredes diferentes | ✅ Superada |
| `PR-WOL-002` | Wake-on-LAN usando el router MikroTik como proxy | ✅ Superada |
| `PR-AUT-004` | Despliegue Multicast + Postdownload + Snapins (automatización completa) | ✅ Superada |
| `PR-MON-001` | Recepción de alerta por Telegram ante caída de servicio | ✅ Superada |

*(El listado completo de pruebas está disponible en la sección 5 de la memoria)*

---

## ▶️ Cómo Usar / Reproducir el Entorno

1.  **Requisitos previos:** Servidor Proxmox VE, red configurada con los bridges `vmbr207`, `vmbr217`, `vmbr227`, `vmbr237`.
2.  **Crear la VM (Ubuntu Server):** Instalar con soporte LVM. Clonar este repositorio dentro de la máquina.
3.  **Configurar IP estática y ampliar almacenamiento:** Seguir la guía de los anexos.
4.  **Instalar FOG Project:** `cd fogproject/bin && sudo ./installfog.sh` (elegir opciones: DHCP activo, HTTPS no).
5.  **Configurar servicios de red:**
    - Modificar `/etc/dhcp/dhcpd.conf` (añadir subredes 172.18.x.0/24).
    - Configurar `dnsmasq` como ProxyDHCP.
    - Configurar `smcroute` para Multicast y reglas `iptables` para WOL (ver scripts).
6.  **Configurar router (R1-Ubuntu o MikroTik):**
    - R1-Ubuntu: `isc-dhcp-relay`, `smcroute`, reglas de iptables.
    - MikroTik: IGMP Proxy, usuario restringido para WOL.
7.  **Registrar hosts y desplegar software:** Utilizar los scripts y Snapins proporcionados.

> **Recomendación:** Para una guía paso a paso, consultar los anexos de la memoria principal y los scripts de configuración en este repositorio.

---

## 📈 Líneas de Mejora Futura

- **Panel Web para Wake-on-LAN (Dockerizado):** Interfaz gráfica que permita seleccionar hosts/grupos y enviar WOL desde el router MikroTik con feedback visual.
- **HTTPS en FOG:** Migrar a certificados SSL para la interfaz web una vez se valide la compatibilidad total con todos los clientes del centro.
- **Redundancia de almacenamiento:** Implementar cluster de Storage Nodes o replicación síncrona para alta disponibilidad.

---

## 👤 Autor

- **Nombre:** [Cristóbal Suárez Abad]
- **Ciclo:** 2º ASIR (Administración de Sistemas Informáticos en Red)
- **Centro:** I.E.S. Delgado Hernández
- **Contacto:** [cristobal@tudominio.com / usuario de GitHub]

---

## 📜 Licencia

Este proyecto se distribuye bajo los términos de la licencia **GNU General Public License v3.0**. El software empleado (FOG Project, Ubuntu, etc.) es de código abierto y gratuito.

---

## 📚 Referencias y Documentación

- [Documentación Oficial de FOG Project](https://docs.fogproject.org/)
- [Wiki de FOG Project](https://wiki.fogproject.org/)
- [Repositorio Oficial en GitHub](https://github.com/FOGProject/fogproject)
