# LESSONS.md — Erros já cometidos nessa dotfile e como não repetir

Esse arquivo existe pra eu (Claude) e pra você não repetirmos os mesmos bugs.
Toda vez que eu mexer nesse repo de novo, eu leio isso primeiro.

## 1. NUNCA jogue saída de comando crua dentro de um arquivo gerado

Aconteceu **três vezes** nesse projeto, sempre pelo mesmo motivo raiz:

- `warn()`/`log()` imprimiam com códigos ANSI de cor no **stdout**, e foram
  chamadas dentro de um bloco `{ ... } > arquivo.lua` — o código de cor foi
  parar dentro do arquivo e quebrou a sintaxe Lua.
  **Fix permanente**: `log`/`warn`/`err` sempre mandam pro **stderr**
  (`>&2`), nunca stdout, em qualquer script.

- `$GPU_INFO` (saída do `lspci`) foi interpolada direto num comentário Lua
  (`echo "-- GPU detectada: $GPU_INFO"`). Se a variável tiver uma quebra de
  linha escondida, o comentário `--` quebra no meio da linha e sobra texto
  solto que o Lua tenta interpretar como código.
  **Fix permanente**: qualquer variável dinâmica que vai pra dentro de um
  arquivo gerado passa antes por `tr '\n\t' '  ' | tr -s ' '` pra virar uma
  linha só, garantido. Regra geral: **nunca confie que a saída de um
  comando é uma linha só só porque "normalmente é"**.

## 2. Hex de cor com 9+ dígitos quebra QUALQUER parser CSS (GTK ou navegador)

Bug: `@define-color surface #1a1c1eee;` tinha uma "cola manual" de sufixo de
alpha (`ee`) em cima de uma cor que às vezes já vinha formatada. CSS só
aceita `#RGB`, `#RGBA`, `#RRGGBB`, `#RRGGBBAA` — nada mais.

**Regra permanente**: matugen (ou qualquer gerador de tema) deve emitir
SEMPRE `#RRGGBB` puro (6 dígitos). Transparência nunca é colada na string
da cor — é aplicada na hora do uso, com a função `alpha(@cor, 0.5)` do
próprio GTK CSS.

## 3. Hyprland: `rgba()`/`rgb()` no config querem hex SEM `#`, não RGB decimal

`hl.env`/`hyprlock.conf`/`hypr/colors.lua` usam `rgba(a8c7faee)` — hex puro,
sem `#`, direto colado com o alpha. O matugen tem dois filtros diferentes:
- `.hex` → `#a8c7fa` (com #, pra CSS)
- `.hex_stripped` → `a8c7fa` (sem #, pra Hyprland/hyprlang)
- `.rgb` → `168, 199, 250` (decimal, NÃO serve pra `rgba()` do Hyprland)

Usar `.rgb` dentro de `rgba(...)` do Hyprland é o bug errado — só percebe
quando o Hyprland já tá tentando carregar o config e falha.

## 4. Waybar usa GTK3 DE VERDADE — não é um CSS "capado"

Confirmado na wiki oficial, numa discussão dos próprios devs, e no
`style.css` padrão que vem com a Waybar: `box-shadow`, `@keyframes` e
`animation` são **suportados oficialmente**. O erro que gerou a falsa
conclusão "evita isso tudo" foi um bug de sintaxe específico:

**GTK CSS não aceita seletor combinado em `@keyframes`** tipo
`0%, 100% { opacity: 1; }`. Precisa de um bloco por porcentagem:

```css
@keyframes pulse {
  0%   { opacity: 1; }
  50%  { opacity: 0.5; }
  100% { opacity: 1; }
}
#elemento {
  animation-name: pulse;
  animation-duration: 1.5s;
  animation-timing-function: ease-in-out;
  animation-iteration-count: infinite;
}
```

Prefira as propriedades separadas (`animation-name`, `animation-duration`
etc) em vez do shorthand `animation: pulse 1.5s ease-in-out infinite;` —
mais previsível no parser do GTK.

## 5. Nomes de pacote AUR: sempre confirmar antes de colocar no installer

Já aconteceu de eu inventar/chutar nome de pacote (`kvantum-theme-materialyou-git`,
`lib32-gamemode` que não existe) e o nome real da PASTA instalada não bater
com o nome do PACOTE (ex: pacote `sddm-theme-sugar-candy-git` instala em
`/usr/share/sddm/themes/Sugar-Candy`, com maiúsculas, não `sugar-candy`).

**Regra permanente**:
- Nunca cravar um nome de pacote sem confirmar (web_search) que ele existe
  de verdade no repo oficial ou no AUR.
- Quando o nome da pasta/arquivo instalado pode variar entre forks/versões
  do pacote, **detectar em runtime** (`find ... -iname`) em vez de chutar
  um nome fixo no script.

## 6. `qt5ct` é o configurador visual, não um daemon

Rodar `qt5ct` no autostart do Hyprland abre a janela de configurações toda
vez que loga — não é isso que aplica o tema. O tema Qt é aplicado sozinho
via `QT_QPA_PLATFORMTHEME=qt5ct` + o `~/.config/qt5ct/qt5ct.conf` já
configurado. `qt5ct` só deve ser executado quando o usuário quer editar
manualmente.

## 7. Pacotes referenciados em config mas nunca instalados

Vários bugs foram simplesmente "uso X no bind/config mas esqueci de
colocar X no installer": `hyprlock`, `hypridle`, `hyprpaper`, `pavucontrol`,
`papirus-icon-theme` (referenciado em 3 lugares, instalado em nenhum).

**Regra permanente**: depois de qualquer mudança no installer ou nos
configs, rodar uma varredura cruzando todo comando usado em
binds/autostart/window_rules contra a lista de pacotes do `install.sh`
antes de entregar.

## 8. chsh falha silenciosamente sem aviso claro

`chsh -s $(which zsh)` falha com "Shell não alterado" se o caminho não
tiver listado em `/etc/shells`. Sempre garantir isso antes:
```bash
grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
```

## 9. hyprpaper cacheia textura pelo CAMINHO do arquivo

Sobrescrever o mesmo `current.jpg` no disco NÃO faz o hyprpaper recarregar
a imagem — ele já tem a textura em memória associada aquele path. Solução:
alternar entre dois nomes reais (`wall-a.jpg`/`wall-b.jpg`), usar
`current.jpg` como symlink estável pra outras configs (hyprlock, SDDM), e
mandar `hyprctl hyprpaper preload/wallpaper/unload` explicitamente a cada
troca.

## 10. GPU muito antiga (pré-GCN / TeraScale) não é bug de config

Detectar pelo **driver de kernel em uso** (`radeon` vs `amdgpu`), não só
pela string "AMD" — placas TeraScale (pré-2012) não têm Vulkan, então
instalar `vulkan-radeon` nelas não faz nada. Nesses casos o caminho certo é
forçar renderização por software (`LIBGL_ALWAYS_SOFTWARE=1`) direto no
`gpu.lua`, e avisar o usuário que o teto de performance é da placa, não da
config.

## 11. Hardware acceleration quebrando apps GPU-pesados (kitty)

Segfault sem log é a assinatura clássica de crash em EGL/OpenGL. Testar
com `LIBGL_ALWAYS_SOFTWARE=1 <app>` confirma se é driver antes de mexer em
qualquer outra coisa. `kitty-safe.sh` (wrapper com fallback automático pra
software rendering em caso de exit 139) é uma rede de segurança, não
substitui achar a causa raiz.

## 12. Custom modules da waybar: `printf "%b"` corrompe o JSON, e `read` posicional quebra com /proc/stat moderno

Dois bugs reais achados em `waybar-cpu.sh`/`waybar-mem.sh` ao testar a
saída de verdade (nunca confiar só na leitura do código):

- `printf '...%b...' "$tooltip"` com `%b` **interpreta** o `\n` da string
  e vira uma quebra de linha crua dentro do JSON — JSON não aceita
  controle cru dentro de uma string, só o escape `\n` literal (duas
  caracteres: barra + n). **Fix permanente**: usar `%s`, nunca `%b`, pra
  montar tooltip/texto de módulo custom. `%s` passa o `\\n` da string
  adiante sem tocar, que é exatamente o que o parser JSON espera.

- `read -r _ u1 n1 s1 i1 io1 irq1 sirq1 <<< "$linha_do_proc_stat"` com
  número fixo de variáveis quebra em qualquer kernel atual, porque
  `/proc/stat` tem `steal`/`guest`/`guest_nice` no final (existem desde
  ~2.6.24, presentes em qualquer Linux moderno, não é coisa de container)
  — os campos que sobram ficam TODOS concatenados na última variável
  nomeada e destroem qualquer aritmética `$(( ))` feita em cima dela.
  **Fix permanente**: sempre terminar um `read` posicional sobre uma
  linha de tamanho não 100% garantido com um `_` extra no final pra
  descartar sobra (`read -r _ u1 n1 s1 i1 io1 irq1 sirq1 _ <<< "$linha"`).
  **Regra geral**: sempre rodar o script de verdade (`bash script.sh | jq`
  ou `python3 -m json.tool`) depois de editar um custom module, não só
  `bash -n` — `-n` não pega nem erro de aritmética em runtime nem JSON
  malformado.

## 13. Fatos confirmados sobre a API atual (waybar 0.15 / Hyprland 0.55+ / matugen) — não repesquisar

- **Roles de cor que o matugen expõe** (confirmado no wiki oficial
  `InioX/matugen`): todo par `<role>`/`on_<role>` de primary, secondary,
  tertiary, error, mais surface/surface_variant/on_surface/
  on_surface_variant, outline, outline_variant, shadow, scrim,
  background/on_background, e as variantes `*_container`.
  **CORREÇÃO (ver item 14)**: o path completo até `.hex` é
  `colors.<role>.default.hex` (ou `.light.hex`/`.dark.hex`) — **não**
  `colors.<role>.hex` direto. O texto antigo desta lição estava errado
  e foi o que gerou o bug do item 14; todos os templates do projeto já
  foram corrigidos pra usar `.default.hex`/`.default.hex_stripped`.
- **Hyprland 0.55+ trocou dispatch por API Lua**: `hyprctl dispatch` com
  sintaxe antiga (`workspace e+1`) não é mais o padrão documentado; a
  wiki oficial (Status bars) mostra
  `hyprctl dispatch 'hl.dsp.focus({workspace="e+1"})'` pra scroll trocar
  de workspace no waybar.
- **`-gtk-icon-transform` só funciona em ícone de verdade** (GtkImage/
  ícone resolvido pelo icon-theme, tipo o do tray ou o `"icon": true` do
  `hyprland/window`) — **não faz nada** em glifo de Nerd Font dentro de
  um label de texto (que é como praticamente todo ícone deste projeto é
  renderizado). Não perder tempo tentando animar transform nesses glifos.
- **`window#waybar` ganha classes de estado direto do compositor/da
  bateria**: `.fullscreen`, `.battery-<state>` (ex. `.battery-critical`),
  entre outras — dá pra estilizar a barra inteira, não só um módulo, sem
  nenhum script extra.
- **`group/<nome>` com `drawer`** é a forma nativa de "revelar no hover":
  o primeiro módulo em `"modules"` fica sempre visível (leader), o resto
  aparece com `children-class` estilizável. Zero dependência nova.

## 14. matugen 4.x: `colors.<role>.hex` sem `.default` quebra TODOS os
templates, silenciosamente derrubando a troca de wallpaper no hyprpaper

- **Causa raiz real** (reproduzida com o binário oficial `matugen 4.1.0`
  baixado direto do release do GitHub, não só suposição): desde a
  reescrita do template engine (matugen ~4.0), o path de uma cor deixou
  de ser `colors.<role>.hex` e passou a ser
  **`colors.<role>.default.hex`** (ou `.light.hex`/`.dark.hex` se você
  quiser o valor de um mode específico independente do `--mode` passado
  na CLI). Isso vale pro filtro `.hex_stripped` também
  (`colors.<role>.default.hex_stripped`).
- **TODOS os templates deste projeto** (`hypr-colors.lua`,
  `kitty-colors.conf`, `waybar-colors.css`, `gtk.css`, `dunstrc`,
  `hyprlock.conf`, `sddm-theme.conf.user`) usavam a sintaxe antiga sem
  `.default` e por isso **todos** davam `ResolveError` — não só o sddm
  (o sddm só era o único visível no terminal por estar por último na
  ordem do `config.toml`; testado isoladamente, hyprland/kitty/waybar/etc
  falhavam igual).
- **matugen, ao dar erro em QUALQUER template, não escreve NENHUM
  arquivo de saída** (confirmado rodando com `--dry-run` desligado e
  inspecionando os arquivos de output: ficaram vazios/inexistentes) e
  sai com exit code 1.
- **Isso é o motivo real de o wallpaper nunca aplicar no desktop**: o
  `matugen-wallpaper.sh` tem `set -euo pipefail`; quando `matugen image
  ...` retorna erro, o script morre naquela linha e **nunca chega** nas
  linhas de `hyprctl hyprpaper preload/wallpaper` logo depois. O
  hyprlock continuava mostrando o wallpaper novo só porque o `cp`/`ln
  -sfn` do `current.jpg` roda ANTES do matugen no script, e o hyprlock
  lê esse arquivo do zero a cada trava — dando a falsa impressão de que
  "só o desktop" estava com bug.
- **Fix**: todo `{{colors.X.hex}}`/`{{colors.X.hex_stripped}}` nos
  templates virou `{{colors.X.default.hex}}`/
  `{{colors.X.default.hex_stripped}}`. Validado gerando os 8 arquivos de
  verdade com o matugen 4.1.0 real — exit code 0, cores coerentes nos
  arquivos gerados.
- **Bug secundário, também real, que mascarava esse**: versões recentes
  do matugen (4.x) abrem um prompt interativo de seleção de cor-fonte
  ("Select the color you want to use as source color...") dentro de
  `matugen image`, que também trava/quebra chamadas não-interativas.
  Fix: `--source-color-index 0` (documentado no próprio `--help` da
  versão 4.1.0: "Setting this to any value will not show the selection
  prompt").
- **Fix complementar em `matugen-wallpaper.sh`** (defesa em profundidade,
  não a causa raiz mas evita repetir esse tipo de falha silenciosa no
  futuro): parou de confiar cegamente no `|| true` dos comandos de IPC
  do hyprpaper — agora tenta preload/wallpaper em todos os monitores
  (via `jq` + `hyprctl monitors -j`), **confirma** com `hyprctl hyprpaper
  listactive` se a textura nova ficou ativa e, se não, mata e reinicia o
  `hyprpaper` (que volta a ler o `hyprpaper.conf` padrão, cujo `preload`
  aponta pro symlink `current.jpg` — sobe já com a imagem certa).
- **Regra geral pra não cair nisso de novo**: quando o matugen imprimir
  `ResolveError` em QUALQUER template, sempre assumir que TODOS os
  templates da execução falharam (nenhum arquivo foi escrito), não só o
  que apareceu por último no log — e testar a sintaxe de cor isolada com
  `matugen --config <toml-mínimo-de-1-template> image <img> ...` antes
  de mexer em mais nada.
