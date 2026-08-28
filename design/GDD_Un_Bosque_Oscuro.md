# Un Bosque Oscuro
### Game Design Document — v0.1

**Jam:** Trust No One
**Plataforma:** PC (Web/Itch.io)
**Motor:** Godot
**Equipo:** 2 personas (diseño/programación + arte/programación)
**Duración estimada de una run:** 6–10 minutos

---

## 1. Pitch

Eres un cazador cuya fogata se ha apagado. Debes atravesar el bosque hasta la salida antes de que algo más te encuentre. En el camino escucharás pasos, respiraciones, crujidos — nunca sabrás con certeza si es un venado, un puma, un cazador furtivo, o una familia inocente acampando. Cada decisión que tomes (disparar, iluminar, fotografiar, gritar, ignorar) tiene un costo, y nunca hay una respuesta completamente segura.

Al salir del bosque, una patrulla de rescate te espera. Un noticiero narra tu final, basado en lo que hiciste allá dentro.

**Tema (Trust No One):** el jugador nunca tiene información completa. Confiar cuesta recursos y expone. Desconfiar por defecto también tiene consecuencias morales y narrativas. No hay decisión "segura", solo decisiones con distintos tipos de riesgo.

---

## 2. Referencias e inspiración

- **A Dark Room** — minimalismo, economía de recursos, tensión con poca información.
- **Limbo** — atmósfera visual, siluetas, movimiento lateral continuo.
- **La conjetura del bosque oscuro** — no hay forma de verificar intenciones ajenas a priori; revelarte (hacer ruido, comunicarte) es a la vez la única forma de progresar y la fuente del peligro.
- Interrogatorios policiales / paredón de sospechosos — la semilla original del concepto de "encontrar en quién confiar".

---

## 3. Game Loop

1. El jugador avanza lateralmente por el bosque (input A/D).
2. Al acercarse a zonas de trigger (invisibles), se determina si ocurre un encuentro (probabilidad).
3. Si ocurre encuentro: se saca una "marble" de la bolsa de probabilidad activa (sin reposición).
4. Se dispara el evento: aparece un blob/silueta ambigua, suena una pista sonora, el juego entra en **bullet-time** (desaceleración, no pausa dura).
5. El jugador decide, dentro de la ventana de tiempo, entre:
   - Usar un recurso (escopeta, antorcha/kerosene, cámara)
   - Gritar ("¡Hola!?")
   - Quedarse quieto
   - No hacer nada → cuenta como **ignorar** por defecto al agotarse el tiempo
6. Se resuelve el evento (texto narrativo + consecuencia mecánica: daño, loot, karma).
7. El juego vuelve a velocidad normal, el jugador sigue caminando.
8. Se repite hasta agotar las 10 marbles / llegar a la salida del bosque.
9. Pantalla final: reporte de noticias, determinado por las variables de karma acumuladas.

---

## 4. Mecánicas centrales

### 4.1 Movimiento
- Lateral, tipo Limbo: input A/D, el personaje avanza (no hay retroceso funcional más allá de ajustes menores de posición).
- Durante un encuentro, la velocidad se reduce (bullet-time) pero nunca llega a cero — queda un movimiento residual para mantener tensión.

### 4.2 Bullet-time (ventana de decisión)
- Al triggerear un encuentro, la velocidad del jugador se interpola (Tween, easing suave) de velocidad normal a velocidad reducida.
- Un `Timer` corre en paralelo a velocidad real (no afectado por el slow-motion).
- Se reproduce un pulso de "reloj" (audio) que marca el countdown de forma diegética.
- Si el Timer llega a 0 sin input del jugador, se resuelve automáticamente como **"ignorar"**.
- El audio de pistas y textos suena/aparece a velocidad normal (independiente del slow-motion del player).

### 4.3 Encuentros — bolsa de marbles
- Cada run usa una bolsa fija de 10 marbles (sin reposición), elegida entre 3 bolsas temáticas posibles.
- Esto garantiza distribución de encuentros y evita rachas injustas de aleatoriedad pura.
- El primer encuentro de cualquier bolsa está fijado como un **venado joven** (tutorial inofensivo).

### 4.4 Pistas
- Cada encuentro entrega información parcial y ambigua por dos canales simultáneos:
  - **Sonido/texto de log:** ej. "escuchas pasos pesados y lentos".
  - **Visual (silueta/blob):** un par de "ojos" visibles con distinta altura/separación como pista adicional gratuita.
- Las pistas se solapan intencionalmente entre entidades (una pista nunca resuelve el misterio al 100%), para que el jugador aprenda probabilidades, no respuestas fijas.

### 4.5 Herramientas de resolución

| Herramienta | Función | Recurso | Costo/Riesgo |
|---|---|---|---|
| **Escopeta** | Ataca/elimina la amenaza | Balas | Karma negativo si es inocente; alerta (ruido) permanente |
| **Antorcha / Kerosene** | Revela parcialmente la identidad de la entidad | Kerosene (uso por tiempo) | Atrae más peligro mientras más tiempo se mantiene encendida |
| **Cámara fotográfica** | Aturde + revela visualmente qué es | Rollos de película | Puede generar "horror retrospectivo" (fotografiar la consecuencia de una acción previa); recurso más escaso |
| **Shout ("¡Hola!?")** | Única forma de generar contacto/confianza con entidades humanas; solo humanos responden | Ilimitado o con cooldown corto | Atrae bestias/cazadores hostiles |

### 4.6 Acciones sin costo de recurso
- **Quedarse quieto:** esperar sin actuar (distinto de ignorar por timeout — es una decisión consciente).
- **Ignorar (por timeout o explícito):** seguir caminando sin resolver el evento. Riesgo acumulativo: ignorar repetidamente a una misma entidad aumenta la probabilidad de ataque sorpresa.

---

## 5. Entidades (tabla de diseño)

| Entidad | Pista sonora | Rareza | Comportamiento pasivo | Al disparar | Al iluminar | Al ignorar/quieto | Loot / consecuencia |
|---|---|---|---|---|---|---|---|
| **Venado joven** | Pasos ligeros e irregulares | Común (tutorial fijo + reapariciones) | Huye ante luz/ruido | Muere → comida | Huye (se pierde loot) | Se aleja solo | Comida (sube HP/recursos) |
| **Puma** | Pasos pesados y lentos, silencio antes de atacar | Poco común | Acecha, puede emboscar | Herido/muerto → loot valioso; riesgo si falla | A veces se retira | Riesgo alto de ataque sorpresa | Piel/garra, o daño severo |
| **Cazador furtivo** | Pasos con ritmo humano, tos/murmullo | Poco común | Puede ser hostil o neutral | Elimina amenaza real, o crimen si era inocente | Revela intención parcial (arma visible o no) | Puede atacar primero si es hostil | Munición/provisiones, o karma negativo |
| **Familia/niño acampando** | Voces bajas, llanto/susurros lejanos | Rara | Nunca es amenaza real | Karma catastrófico (peor final posible) | Revela la verdad con claridad | No pasa nada; posible ayuda si te acercas con calma | Provisiones si se maneja con cuidado |
| **Jauría de lobos** | Pasos sincronizados múltiples, aullido distante | Rara, tardía | Peligro real de grupo | Hiere a uno, atrae al resto | Ahuyenta temporalmente | Riesgo de emboscada grupal | Ninguno si se huye; alto riesgo de HP |
| **Sobreviviente perdido** | Pasos erráticos, respiración agitada, posible pedido de ayuda | Poco común | Puede unirse (aliado) o traicionar | Karma negativo, pierde aliado potencial | Revela si está herido/armado | Se pierde para siempre | Aliado (ventaja) o traición (pérdida de recursos) |

---

## 6. Recursos y economía

| Recurso | Cantidad inicial sugerida | Notas |
|---|---|---|
| **Fogata / reloj de luz** | — | Reloj general de la run; determina cuándo "empieza" el peligro (ya agotada al inicio del juego) |
| **HP** | 3–4 golpes | Corazones visibles en UI |
| **Balas (escopeta)** | 4–5 | Alcanza para menos de la mitad de los encuentros |
| **Kerosene (antorcha)** | ~5–6 usos cortos | Reutilizable en cargas breves |
| **Película (cámara)** | 3 | Recurso más escaso |
| **Shout** | Ilimitado o cooldown 1–2 turnos | El riesgo de atraer peligro es su costo natural |

**Principio de balance:** la economía de recursos es deliberadamente insuficiente para resolver los 10 encuentros con certeza total. El jugador debe elegir cuándo gastar información/seguridad, dejando varias decisiones genuinamente a ciegas.

---

## 7. Las 3 bolsas de marbles

| Bolsa | Composición (de 10) | Tono |
|---|---|---|
| **Cacería** | 4 venados, 2 pumas, 3 cazadores furtivos, 1 jauría | Supervivencia física, poco dilema moral |
| **Refugio** | 2 venados, 1 puma, 2 cazadores, 2 sobrevivientes, 2 familias, 1 jauría | Alto peso moral, más encuentros humanos |
| **Salvaje** | 3 venados, 3 pumas, 1 cazador, 1 sobreviviente, 2 jaurías | Amenazas mayormente animales, dilema físico > moral |

*(Nota: en cualquier bolsa, el primer encuentro es siempre el venado joven tutorial.)*

---

## 8. Sistema de finales (karma)

Se rastrean dos ejes ocultos durante toda la run:

- **Eje de violencia:** cantidad de disparos, y si fueron contra amenazas reales o inocentes.
- **Eje de comportamiento social:** si ayudó a otros (familia, sobreviviente) o los ignoró/abandonó/atacó.

| Violencia | Comportamiento social | Final |
|---|---|---|
| Alta, mató inocentes | Egoísta / abandonó a otros | **Psicópata** |
| Alta, solo amenazas reales | Ayudó a alguien | **Héroe nacional** |
| Baja, casi no disparó | Evitó todo contacto | **Caminante perdido** |
| Mató a un inocente específico con testigos vivos | Alguien vivió para contarlo | **Condenado a prisión** |

El resultado se presenta como un **reporte de noticias** (texto tipo breaking news), sin indicadores numéricos visibles al jugador durante la partida — el karma es completamente oculto hasta el final.

---

## 9. Dirección de arte

- **Estilo:** siluetas 1-bit / paleta monocromática (verde-oliva oscuro visto en mockups), atmósfera tipo Limbo.
- **Personaje:** silueta simple, ojos como único punto de luz/identificación.
- **Entidades:** blob/silueta oscura por defecto; solo se revela sprite específico al usar antorcha o cámara. Pista visual barata: par de "ojos" con distinta altura/separación según tipo de entidad.
- **Parallax:** 4+ capas para dar profundidad al bosque.
- **UI:** panel de HP (corazones) arriba-izquierda, log de texto narrativo abajo-izquierda, recursos con contador y botón "Usar" a la derecha.

---

## 10. Audio

- **Pistas sonoras por entidad** (pasos, respiración, voces) — disparadas al inicio de cada encuentro.
- **Pulso de reloj** durante el bullet-time, marcando el countdown de decisión de forma diegética.
- Los efectos de pista/decisión suenan siempre a velocidad normal, independientes del slow-motion del jugador.

---

## 11. Estructura técnica (Godot) — sistemas a implementar

Ordenados de menor a mayor complejidad estimada:

1. Movimiento lateral (CharacterBody2D + input A/D)
2. Parallax (ParallaxBackground / ParallaxLayer)
3. Cámara siguiendo al jugador
4. Sistema de HP/vida (UI de corazones)
5. Sistema de recursos/inventario (balas, kerosene, película)
6. Triggers de encuentro (Area2D, zonas invisibles)
7. Sistema de reproducción de sonidos (pool / autoload de audio)
8. Sistema de log/texto en pantalla (estilo diálogo)
9. Sistema de estados del personaje / sprites
10. Bolsa de marbles + spawning de encuentros
11. Sistema de bullet-time (Tween de velocidad + Timer de decisión)
12. Sistema de karma / tracking de finales
13. Pantalla final / reporte de noticias

---

## 12. Preguntas abiertas / pendientes de definir

- Redacción final de todas las variantes de texto por entidad y por herramienta usada (pistas, resoluciones, ambigüedad).
- Balance exacto de rareza dentro de cada bolsa y probabilidad de trigger por distancia recorrida.
- Duración exacta de la ventana de bullet-time y curva de desaceleración.
- Definición de "riesgo acumulado" al ignorar repetidamente una misma entidad (fórmula o tabla).
- Redacción de los 4 (o más) reportes de noticias finales.
- Resolución final de pantalla/canvas a confirmar con el dev de arte (mockups actuales sugieren resolución mayor a la retro clásica 320×180).

---

*Documento vivo — versión inicial generada a partir de sesión de brainstorming. Sujeto a revisión y expansión.*
