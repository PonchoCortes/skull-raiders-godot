# Skull Raiders — Prototipo en Godot 4.6

Este es el **primer paso** de la migración de tu juego (React + Matter.js) a Godot.
No es el juego completo — es un prototipo de **un nivel jugable** para validar que
la física del cañón (gravedad + viento) se siente igual que en el original, antes
de construir los 100 niveles, los 10 jefes, las animaciones LPC, el menú completo, etc.

## Qué incluye este prototipo

- Menú principal básico con botón "Jugar".
- Un nivel con tu barco (`ship_player.png`) y un barco enemigo (`ship_enemy.png`).
- Cañón: mantené click izquierdo para apuntar hacia el mouse y cargar potencia,
  soltá para disparar.
- Física de la bala de cañón replicando la fórmula del juego original
  (`ax = windX * 0.3`, `ay = gravity`, ver `PirateGame.jsx` líneas ~822-823).
- El barco enemigo tiene 3 "vidas" (como los minions de 3 HP del original);
  al perderlas todas se hunde y aparece pantalla de victoria.
- Línea de trayectoria mientras apuntás (igual que `drawTrajectoryGuide` del original).

## Cómo abrirlo en Godot

1. Descomprimí este zip.
2. Copiá todo el contenido a la carpeta de tu repositorio de GitHub
   (`skull-raiders-godot` o el nombre que prefieras), o subilo directo como
   repo nuevo.
3. Abrí Godot 4.6 → botón **Importar** → seleccioná la carpeta donde quedó
   el archivo `project.godot` → **Importar y Editar**.
4. Adentro del editor, arriba a la derecha, apretá el botón de **Play** (▶)
   o F5. La primera vez Godot te va a preguntar cuál es la escena principal:
   elegí `scenes/MainMenu.tscn` si te lo pide (ya debería estar configurada sola).
5. Deberías ver el menú → click en "JUGAR" → mantené click y soltá para disparar
   contra el barco enemigo.

Si algo no abre o tira un error en la consola de abajo del editor, copiame el
texto exacto del error y lo arreglamos.

## Estructura del proyecto

```
project.godot          → configuración del proyecto (ventana 1280x720, escena inicial)
icon.svg                → ícono del proyecto
scenes/
  MainMenu.tscn          → menú principal
  Game.tscn              → nivel jugable (cañón, barco, HUD)
  EnemyShip.tscn          → barco enemigo (vida, flash al recibir daño, animación de hundimiento)
  Cannonball.tscn         → bala de cañón
scripts/
  MainMenu.gd
  Game.gd                 → lógica de apuntado, potencia, física, HUD
  EnemyShip.gd
  Cannonball.gd           → física manual: gravedad + viento por nivel
assets/images/
  ship_player.png
  ship_enemy.png
```

## Lo que falta (hoja de ruta real)

Portar el juego completo implica reconstruir, por partes, cada sistema del
original. Esto es lo que sigue, en orden sugerido:

1. **Sistema de niveles** — traer los 100 niveles de `levels.js` (gravedad,
   viento, cantidad de objetivos, actos) a un recurso de datos en Godot
   (`.tres` o un diccionario en GDScript) y una pantalla de selección de nivel.
2. **Sprites animados LPC** (capitanes y minions, 64x64, 12 filas) — usar
   `AnimatedSprite2D` con `SpriteFrames` cortando cada spritesheet.
3. **Mecánica de capitán** (solo atacable tras derrotar 3 minions).
4. **Los 10 jefes** con sus paletas de color y efectos de partículas.
5. **Audio** — las 5 melodías chiptune + el sea serpent / megalodon / delfín.
6. **Fondos con parallax** y fauna ambiental.
7. **Guardado de progreso** (estrellas por nivel, monedas, modo debug).
8. **Versión 3D** con tus modelos `.glb` — esto es un salto aparte: cambia
   cámara, colisiones e iluminación. Mandame los `.glb` cuando los tengas y
   evaluamos si convertimos el juego a 3D completo o si hacemos una versión
   híbrida (barcos 3D, HUD 2D).

Te recomiendo que primero probemos este prototipo, me digas qué se siente
distinto respecto al original (potencia del disparo, curva de la trayectoria,
tamaño de los barcos, etc.), y a partir de ahí seguimos con el punto 1
(sistema de niveles) para tener varios niveles jugables antes de meter jefes
y sprites animados.

## Cómo animar el modelo 3D del pirata (pirata_malo.glb)

El archivo que subiste (`pirata_malo.glb`) es solo la malla del personaje —
no trae huesos ni animaciones adentro. Crear un esqueleto y "pintar" qué
vértices mueve cada hueso (rigging) es un trabajo que necesita una
herramienta como Blender, y normalmente ojo humano para que no queden
deformaciones raras. No es algo que se pueda generar bien solo con código.

La forma más simple, gratis y sin programar de resolver esto es **Mixamo**
(de Adobe), que auto-riggea modelos humanoides y te da animaciones ya
hechas (caminar, atacar, recibir daño, morir):

1. Entrá a mixamo.com (necesitás una cuenta gratis de Adobe).
2. Subí `pirata_malo.glb` (si no lo acepta directo, exportalo antes a
   `.fbx` desde Blender — File > Import glTF, luego File > Export FBX).
3. Mixamo va a pedirte que marques manualmente algunos puntos del cuerpo
   (mentón, codos, rodillas, muñecas) sobre el modelo — es un par de clicks,
   te guía con una imagen.
4. Una vez rigged, elegí animaciones del catálogo (Idle, Walk, Sword Attack,
   Hit Reaction, Death son las que más vamos a necesitar) y descargalas
   como `.fbx` con "Skin" incluido en la primera, y sin skin en las siguientes
   (para no duplicar la malla).
5. Metés esos `.fbx` en la carpeta `assets/models/` del proyecto y los
   importás en Godot — ahí Godot los reconoce automáticamente como
   `Skeleton3D` + `AnimationPlayer`.
6. Mandame esos archivos (o decime que ya los tenés en el repo) y yo armo
   el `AnimationTree` y lo conecto a la lógica del juego.

Mientras tanto, ya dejé el modelo cargado en `scenes/PiratePreview3D.tscn`
para que lo puedas ver girando en Godot, aunque todavía no se mueva.
