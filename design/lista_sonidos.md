# Lista de Sonidos — Un Bosque Oscuro

Basado en el GDD (§4.5, §5, §10) y en lo ya implementado en código.

---

## Prioridad alta — ya tienen gancho en el código, solo falta el archivo

- **`torch_ignite`** — encendido de la antorcha. Ya conectado (`player.gd`, `AudioStreamPlayer` "TorchIgniteSound"); solo falta el archivo.
- **`gunshot`** — disparo de la escopeta. Ya tiene el screen shake armado, le falta el sonido para sentirse completo.
- **`camera_shutter`** — flash/obturador de la cámara. Ya tiene el flash visual de la máscara de visión.
- **`shout`** — el grito ("¡Hola!?", tecla Space). Es una mecánica sorpresa sin ícono ni texto en el HUD — sin sonido, el jugador no tiene ninguna señal de que la acción ocurrió.

---

## Prioridad media — game feel central, todavía sin conectar

- **`footstep`** (uno o varias variantes para alternar) — pasos al caminar. Con el ciclo de 6 frames del walk ya animado, esto le daría mucho peso.
- **`player_hurt`** — al recibir daño (`GameManager.take_damage()` ya existe, sin sonido asociado).
- **`player_death`** — al morir / transición a game over.
- **`ambient_forest_loop`** — loop de fondo (viento, bosque nocturno) para atmósfera constante durante el nivel.

---

## Prioridad baja — para cuando implementemos encuentros (Etapa 8, todavía no existe)

- **`decision_clock_tick`** — el pulso de reloj diegético durante el bullet-time (GDD §4.2: "marca el countdown... suena siempre a velocidad normal, independiente del slow-motion"). Ligado al ícono del reloj que ya está en el HUD pero sin lógica todavía.
- **Pistas sonoras por entidad** (GDD §5, una por criatura — se solapan a propósito, ninguna resuelve el misterio al 100%):
  - `steps_deer` — pasos ligeros e irregulares (venado joven)
  - `steps_puma` — pasos pesados y lentos, silencio antes de atacar (puma)
  - `steps_poacher` — pasos con ritmo humano + tos/murmullo (cazador furtivo)
  - `voices_family` — voces bajas, llanto/susurros lejanos (familia acampando)
  - `pack_howl` — pasos sincronizados múltiples + aullido distante (jauría de lobos)
  - `steps_survivor` — pasos erráticos + respiración agitada (sobreviviente perdido)
- **UI polish** (opcional): `menu_hover`, `menu_confirm` — clicks/hover en botones de menú.

---

*Lista viva — igual que `lista_sprites.md`, actualizar a medida que agreguemos etapas del GDD. Los nombres son sugerencias de archivo (`.wav`/`.ogg`), no hace falta que coincidan exacto — avisame el nombre real al soltarlos en `assets/audio/` y los conecto.*
