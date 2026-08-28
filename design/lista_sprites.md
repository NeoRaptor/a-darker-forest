# Lista de Sprites — Un Bosque Oscuro

Basado en el GDD (§5, §9) y el mockup (`mockup a darker forest.png`). Resolución base del viewport: **384×216**. El jugador mide ~10×24px (ver `CollisionShape2D` en `player.tscn`), así que todo el arte de personajes/entidades debe pensarse a esa escala — es un juego de siluetas pequeñas, no de sprites grandes y detallados.

Paleta: monocromática verde-oliva oscuro (ya definida en `CanvasModulate` de `level_1.tscn`: `Color(0.06, 0.1, 0.08)`), con los "ojos" y elementos de luz en blanco/crema cálido como único punto de contraste fuerte.

---

## Prioridad alta (bloquean las próximas etapas: 6, 7, 8)

### 1. Jugador (Cazador)
- `hunter_idle` — silueta base parada, ~10×24px. Reemplaza el `ColorRect` placeholder de `HunterSprite` en `player.tscn`.
- `hunter_walk` — ciclo de caminata, 2–4 frames. El flip de dirección ya se maneja en código (`player.gd`), así que con una sola dirección alcanza.
- `hunter_eyes` — el par de puntos claros (ya hay un `PointLight2D` para el glow; conviene un sprite base debajo para que se vea aunque la luz esté débil).

*(Opcional / pulido, no bloqueante: poses sosteniendo antorcha/escopeta/cámara — el GDD no lo exige explícitamente, se puede posponer.)*

### 2. Entidad ambigua — blob genérico (antes de revelar)
La ambigüedad es una mecánica (§4.4: "una pista nunca resuelve el misterio al 100%"), así que **no** se necesita un blob distinto por entidad — con 2–3 tamaños reutilizables alcanza:
- `entity_blob_small` (venado, sobreviviente)
- `entity_blob_medium` (puma, cazador furtivo)
- `entity_blob_large` (jauría, familia — grupo)
- `entity_eyes_pair` — un solo sprite de 2 puntos, reescalado/reposicionado por código según la entidad (altura y separación distinta, §4.4).

### 3. Entorno / Parallax (4 capas, ya con `ColorRect` placeholders en `parallax_background.tscn`)
- `tree_layer_far` — pinos lejanos, silueta más clara/desaturada
- `tree_layer_mid_far`
- `tree_layer_mid_near`
- `tree_layer_foreground` — la más oscura y detallada, la que tapa parcialmente al jugador (como en el mockup)
- `ground_texture` — pasto/tierra del sendero, reemplaza `GroundColor`
- `particles_dust` — las motas blancas flotantes que se ven en el mockup (polvo/luciérnagas)

### 4. Iconos HUD (confirmados por el mockup)
- `icon_heart_pulse` — el primer corazón especial (ícono de pulso/latido, distinto a los demás)
- `icon_heart_full` / `icon_heart_empty`
- `icon_clock` — reloj arriba a la derecha (reloj de luz/fogata, GDD §6)
- `icon_torch`
- `icon_camera`
- `icon_shotgun`
- `icon_shout` — no aparece en el mockup pero el GDD lo pide (§4.5); diseñarlo a juego con los otros 3
- `ui_panel_frame` — marco con borde tipo 9-slice, usado en el panel de diálogo y en los botones "Usar" / "Quedarse quieto" / "Ignorar"

---

## Prioridad media (necesarios para la Etapa 8 — resolución de encuentros)

### 5. Sprites revelados por entidad (al usar antorcha o cámara, §5 y §9)
Una pose estática por entidad alcanza para el jam; animar solo si sobra tiempo.
- `deer_young` (venado joven — tutorial)
- `puma`
- `poacher` (cazador furtivo)
- `family` (familia acampando, posible fogata pequeña de apoyo visual)
- `wolf_pack` (¿sprite grupal, o 1 lobo repetido 2-3 veces por código?)
- `lost_survivor` (sobreviviente perdido)

### 6. Efectos (FX)
- `fx_muzzle_flash` (disparo de escopeta)
- `fx_camera_flash`
- `fx_torch_flame` — llama animada, complementa el `PointLight2D` que ya existe en `player.tscn`
- `fx_fog_overlay` — reemplaza el `ColorRect` de niebla actual en la capa foreground

---

## Prioridad baja (pantallas especiales, se pueden dejar para el final)

- `campfire_extinguished` — fogata apagada, para la intro ("tu fogata se ha apagado")
- `rescue_patrol` — linternas/patrulla de rescate, pantalla final
- `news_report_frame` — marco tipo noticiero/breaking news para `game_over.tscn`
- `main_menu_background` — arte de fondo del menú principal (puede ser una variante del mockup ya hecho)

---

*Lista viva — actualizar a medida que se implementen las etapas del GDD (ver conversación de plan por etapas). Cruza referencias de nombres de nodo (`HunterSprite`, `EyesLight`, `TorchLight`, etc.) con `scripts/player/player.gd` y `scenes/game/*.tscn` para mantener consistencia al integrar el arte final.*
