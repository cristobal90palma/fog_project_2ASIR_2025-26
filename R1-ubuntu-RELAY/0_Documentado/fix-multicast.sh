#!/bin/bash
# Esperamos 10 segundos para que todas las interfaces de red estén UP
sleep 10
# Ejecutamos el comando que funciona manualmente
/usr/sbin/smcroutectl add eth207 10.2.7.5 233.254.7.5 eth217 eth227 eth237
